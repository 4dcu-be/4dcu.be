---
layout: post
title:  "Better Raspberry Pi Pico MIDI controller"
byline: "adding modifier keys and chord support"
date:   2021-12-16 06:00:00
author: Sebastian Proost
categories: diy
tags:	raspberry-pi python mechanical-keyboard soldering electronics midi
cover:  "/assets/posts/2021-12-16-MIDIpad_update/midipad_button_mapping.jpg"
thumbnail: "/assets/images/thumbnails/midipad2.jpg"
---

To expand the number of notes/chords my RP2040 based [MIDI controller]({% post_url 2021/2021-05-20-MIDIpad %}) can play we'll 
turn two keys into modifiers. This way the other 7 buttons can actually each be assigned 4 different notes/chords (a default,
pressed with modifier one, pressed with modifier two and pressed with both modifiers active). So we go from 9 notes/chords to 
28 different options, which should expand the number of songs that can be played substantially.

While at first glance this seems like an easy task, there are a few things that need to be taken into consideration. A
MIDI device sends a signal once a note is pressed and one when it is released. In the previous post this was straightforward; each
button was playing two notes one octave apart, and there was no overlap between buttons. So when a button goes down, 
the corresponding notes can start, if that button goes up those notes can be started again, easy ...

![New each button maps to 4 chords, depending on which modifiers are pressed](/assets/posts/2021-12-16-MIDIpad_update/midipad_button_mapping.jpg)

When assigning proper chords to buttons, things get more complex. Imagine a key that plays a C chord, once pressed a signal
is sent to play notes C, E and G. If that key is released a signal to stop those notes is needed. However, if another 
key playing an E chord (E-G#-Bb) is pressed without releasing the former, there is an overlapping note. So 
releasing the C chord button should **not** stop playing the E note. To do this we need to keep track of a few things: 
which modifiers were active when a button was pressed and which notes are currently playing. That way we can figure 
out at any given time which notes should be playing and which need to be stopped. This is a bit of extra overhead, 
fortunately the RP2040 chip has plenty of power to do this without much issue.

How to build the keypad is discussed [here]({% post_url 2021/2021-04-05-Macropad %}). This post includes a part list, 
all schematics you'll need along with STL files for the 3D printed parts. If you are new to MIDI devices you might want
to start with the [previous post]({% post_url 2021/2021-05-20-MIDIpad %}) as this is an easier starting point.

## MIDIPad v2.0 - the code

Here is the full code which can also be downloaded [here](./assets/posts/2021-12-16-MIDIpad_update/midapad_2.py). Note that this is intended to work with [CircuitPython] 
and requires the [AdaFruit MIDI] library to be installed on the device. Below the code some major changes will
be highlighted. This file needs to be renamed to ```code.py``` and put in the root directory of the Pi Pico.

{:.large-code}
```python
import board
import digitalio
import pwmio
import time

import usb_midi
import adafruit_midi

from adafruit_midi.note_on import NoteOn
from adafruit_midi.note_off import NoteOff


midi = adafruit_midi.MIDI(midi_out=usb_midi.ports[1], out_channel=0)

print("MacroPad MIDI Board")

print("Default output MIDI channel:", midi.out_channel + 1)

# Configuration, which LED pins are used, which buttons, how buttons map to notes
led_pins = [board.GP18,board.GP17,board.GP16,board.GP21,board.GP20,board.GP19, board.GP27, board.GP26,board.GP22]
button_pins = [board.GP13,board.GP14,board.GP15, board.GP10,board.GP11,board.GP12,board.GP7]
button_led_ix = [0,1,2,3,4,5,6]

modifier_pins = [board.GP8,board.GP9]
modifier_led_ix = [7, 8]

note_mapping = {
    # Notes when no modifier is pressed (major chord)
    0: [
        ["C3", "E3", "G3"],
        ["D3", "F#3", "A3"],
        ["E3", "G#3", "B3"],
        ["F3", "A3", "C4"],
        ["G3", "B3", "D4"],
        ["A3", "C#4", "E4"],
        ["B3", "D#4", "F#4"]],
    # Notes when modifier one is pressed (minor chords)
    1: [
        ["C3", "Eb3", "G3"],
        ["D3", "F3", "A3"],
        ["E3", "G3", "B3"],
        ["F3", "Ab3", "C4"],
        ["G3", "Bb3", "D4"],
        ["A3", "C4", "E4"],
        ["B3", "D4", "F#4"]],
    # Notes when modifier two is pressed (sus2 chords)
    2: [
        ["C3", "D3", "G3"],
        ["D3", "E3", "A3"],
        ["E3", "F#3", "B3"],
        ["F3", "G3", "C4"],
        ["G3", "A3", "D4"],
        ["A3", "B3", "E4"],
        ["B3", "C#4", "F#4"]],
    # Notes when both modifiers are pressed (sus4 chords)
    3: [
        ["C3", "F3", "G3"],
        ["D3", "G3", "A3"],
        ["E3", "A3", "B3"],
        ["F3", "A#3", "C4"],
        ["G3", "C4", "D4"],
        ["A3", "D4", "E4"],
        ["B3", "E4", "F#4"]]
    }
    

# Set up buttons
buttons = [digitalio.DigitalInOut(bp) for bp in button_pins]

for btn in buttons:
    btn.direction = digitalio.Direction.INPUT
    btn.pull = digitalio.Pull.UP

modifiers = [digitalio.DigitalInOut(bp) for bp in modifier_pins]

for modif in modifiers:
    modif.direction = digitalio.Direction.INPUT
    modif.pull = digitalio.Pull.UP

# Set up LEDs
leds = [pwmio.PWMOut(lp, frequency=1000, duty_cycle=0) for lp in led_pins]

# Set Initial Duty Cycles to 0 for each LED
duty_cycles = [0 for _ in led_pins]

# Last Pressed
pressed_keys = [False for _ in button_pins]
triggered_keys = [-1 for _ in button_pins]

pressed_modifiers = [False for _ in modifier_pins]

# Notes playing
notes_playing = []


print("started loop")
while True:
    # Handle modifier buttons
    modifier_value = 0
    for ix, (led_ix, modif) in enumerate(zip(modifier_led_ix, modifiers)):
        pressed_modifiers[ix] = not modif.value
        
        if not modif.value:
            modifier_value += 2 ** ix
            # print(f"pressed modifier {ix}")
            # print(f"current modifier {modifier_value}")
            duty_cycles[led_ix] = 65025
    
    # Handle buttons pressed
    for ix, (led_ix, btn) in enumerate(zip(button_led_ix, buttons)):
        pressed_keys[ix] = not btn.value
        
        if not btn.value:
            # print(f"pressed button {ix}")
            duty_cycles[led_ix] = 65025
            
    
    for ix, (pk, tk) in enumerate(zip(pressed_keys, triggered_keys)):
        if pk and tk < 0:
            print(f"note {ix} started with modifier {modifier_value}")
            triggered_keys[ix] = modifier_value
            # Start all notes in the chord
            midi.send([NoteOn(a, 60) for a in note_mapping[modifier_value][ix]])
            for a in note_mapping[modifier_value][ix]:
                notes_playing.append(a)
        elif not pk and 0 <= tk:
            print(f"note {ix} stopped")
            triggered_keys[ix] = -1
     
    # Check which notes/chords are currently playing after handling buttons
    notes_playing_updated = []
    for ix, tk in enumerate(triggered_keys):
        if 0 <= tk:
            notes_playing_updated = notes_playing_updated + note_mapping[tk][ix]
    
    # Stop notes no longer playing
    notes_to_stop = set(notes_playing) - set(notes_playing_updated)
    midi.send([NoteOff(a, 0) for a in notes_to_stop])
    
    # Move updated list to notes_playing for next cycle
    notes_playing = notes_playing_updated
    
    # Fade effect on LEDs 
    for ix, led in enumerate(leds):
        led.duty_cycle = duty_cycles[ix]
        duty_cycles[ix] = max(duty_cycles[ix] - 900, 0)

    time.sleep(0.01)
```

## Adding in modifier keys

Two buttons have been used as modifier keys, in the program logic these are now handled differently from regular 
buttons that will play some notes. There are additional changes required to make sure we can still match the right
LED to each button correctly. So to do this, a list of pins with buttons is defined as well as a list of the index of
the matching LED. The same is done for the modifier buttons.

```python
# Configuration, which LED pins are used, which buttons, how buttons map to notes
led_pins = [board.GP18,board.GP17,board.GP16,board.GP21,board.GP20,board.GP19, board.GP27, board.GP26,board.GP22]
button_pins = [board.GP13,board.GP14,board.GP15, board.GP10,board.GP11,board.GP12,board.GP7]
button_led_ix = [0,1,2,3,4,5,6]

modifier_pins = [board.GP8,board.GP9]
modifier_led_ix = [7, 8]
```

To accommodate these changes, additional changes throughout the code were necessary. Nothing to complicated, the 
modifier buttons need to be set up separately and when changing the duty cycle for a specific LED, the index from
either ```button_led_ix``` or ```modifier_led_ix``` as there is no longer a 1-to-1 mapping of keys and LEDs.

The modifier keys itself include an old trick. Essentially each modifier key is assigned a value which is
a power of two, so the first on is 1 (2^0), the next 2 (2^1), then 4 (2^2), ... that way if we add the values of all 
pressed modifiers together you get a unique number for each possible combination. Here only two buttons are available
so the modifier value can be 0 (no modifier), 1 (first button pressed), 2 (second button pressed) or 3 (both buttons 
pressed). This is done in the bit of code below and is the first step of the main loop.

```python
    # Handle modifier buttons
    modifier_value = 0
    for ix, (led_ix, modif) in enumerate(zip(modifier_led_ix, modifiers)):
        pressed_modifiers[ix] = not modif.value
        
        if not modif.value:
            modifier_value += 2 ** ix
            # print(f"pressed modifier {ix}")
            # print(f"current modifier {modifier_value}")
            duty_cycles[led_ix] = 65025
```

## Playing chords

The biggest hurdle with playing chords is that notes within different chords can overlap. So the logic to start and stop
playing certain notes needed to be upgraded.

In the previous version we tracked which keys were pressed (so we could release them correctly) and if the notes 
associated with that key were playing already (or triggered). Now we'll need to keep track of which modifiers were 
active when a key is triggered. So rather than using boolean logic we'll set the trigger to -1 (not triggered) or the
modifier value (0-3) if a button is pressed. 

{:.large-code}
```python
    for ix, (pk, tk) in enumerate(zip(pressed_keys, triggered_keys)):
        if pk and tk < 0:
            print(f"note {ix} started with modifier {modifier_value}")
            triggered_keys[ix] = modifier_value
            # Start all notes in the chord
            midi.send([NoteOn(a, 60) for a in note_mapping[modifier_value][ix]])
            for a in note_mapping[modifier_value][ix]:
                notes_playing.append(a)
        elif not pk and 0 <= tk:
            print(f"note {ix} stopped")
            triggered_keys[ix] = -1
     
    # Check which notes/chords are currently playing after handling buttons
    notes_playing_updated = []
    for ix, tk in enumerate(triggered_keys):
        if 0 <= tk:
            notes_playing_updated = notes_playing_updated + note_mapping[tk][ix]
    
    # Stop notes no longer playing
    notes_to_stop = set(notes_playing) - set(notes_playing_updated)
    midi.send([NoteOff(a, 0) for a in notes_to_stop])
    
    # Move updated list to notes_playing for next cycle
    notes_playing = notes_playing_updated
```

## Which chords to pick ? And how to define them ?

The short answer is, you add in the chords you need. I picked from a major scale the major chords (C, D, E, F, G, A 
and B) and modifiers can be used to turn these into minor chords, sus2 chords or sus4 chords. These are defined in
a dictionary in the beginning of the code called ```note_mapping```, the key is the modifier which is active and the
value is a list of chords matching the buttons defined.

Note that it is extremely easy to modify the chords to match your preferences. Simply add/remove/change notes to 
this list and done!

{:.large-code}
```python
note_mapping = {
    # Notes when no modifier is pressed (major chord)
    0: [
        ["C3", "E3", "G3"],
        ["D3", "F#3", "A3"],
        ["E3", "G#3", "B3"],
        ["F3", "A3", "C4"],
        ["G3", "B3", "D4"],
        ["A3", "C#4", "E4"],
        ["B3", "D#4", "F#4"]],
    # Notes when modifier one is pressed (minor chords)
    1: [
        ["C3", "Eb3", "G3"],
        ["D3", "F3", "A3"],
        ["E3", "G3", "B3"],
        ["F3", "Ab3", "C4"],
        ["G3", "Bb3", "D4"],
        ["A3", "C4", "E4"],
        ["B3", "D4", "F#4"]],
    # Notes when modifier two is pressed (sus2 chords)
    2: [
        ["C3", "D3", "G3"],
        ["D3", "E3", "A3"],
        ["E3", "F#3", "B3"],
        ["F3", "G3", "C4"],
        ["G3", "A3", "D4"],
        ["A3", "B3", "E4"],
        ["B3", "C#4", "F#4"]],
    # Notes when both modifiers are pressed (sus4 chords)
    3: [
        ["C3", "F3", "G3"],
        ["D3", "G3", "A3"],
        ["E3", "A3", "B3"],
        ["F3", "A#3", "C4"],
        ["G3", "C4", "D4"],
        ["A3", "D4", "E4"],
        ["B3", "E4", "F#4"]]
    }
```

## Conclusion

The MIDIpad now can play 28 different chords, which is a substantial increase for the 9 from the last version. Also
overlapping notes between chords are now handled correctly. So with a little extra effort the little keypad suddenly
gained a few new tricks. Though there is still an issue with using normal switches, they don't detect how hard a note
is pressed ... This is still something I'd like so solve in a future post!

[CircuitPython]: https://circuitpython.readthedocs.io/
[AdaFruit MIDI]: https://github.com/adafruit/Adafruit_CircuitPython_MIDI
