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
led_pins = [board.GP18, board.GP17, board.GP16, board.GP21, board.GP20, board.GP19, board.GP27, board.GP26, board.GP22]
button_pins = [board.GP13, board.GP14, board.GP15, board.GP10, board.GP11, board.GP12, board.GP7]
button_led_ix = [0, 1, 2, 3, 4, 5, 6]

modifier_pins = [board.GP8, board.GP9]
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
