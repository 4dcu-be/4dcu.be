---
layout: post
title:  "Een betere Raspberry Pi Pico-MIDI-controller"
byline: "met modificatietoetsen en ondersteuning voor akkoorden"
description: "Een Raspberry Pi Pico-MIDI-controller uitbreiden met modificatietoetsen en ondersteuning voor akkoorden in CircuitPython, van 9 naar 28 speelbare noten en akkoorden."
date:   2021-12-16 06:00:00
author: Sebastian Proost
post_id: midipad-update
categories: diy
tags:	raspberry-pi python mechanical-keyboard soldering electronics midi
cover:  "/assets/posts/2021-12-16-MIDIpad_update/midipad_button_mapping.jpg"
thumbnail: "/assets/images/thumbnails/midipad2.jpg"
---

Om het aantal noten en akkoorden uit te breiden dat mijn RP2040-gebaseerde [MIDI-controller]({% post_url nl/2021/2021-05-20-MIDIpad %}) kan spelen, maken we van 
twee toetsen modificatietoetsen. Zo kunnen aan elk van de zeven andere knoppen vier verschillende noten of akkoorden worden toegewezen (standaard,
met modificatietoets één ingedrukt, met modificatietoets twee ingedrukt en met beide modificatietoetsen actief). We gaan dus van 9 noten of akkoorden naar 
28 verschillende opties, wat het aantal speelbare nummers aanzienlijk moet vergroten.

Hoewel dit op het eerste gezicht eenvoudig lijkt, zijn er enkele zaken waarmee we rekening moeten houden. Een
MIDI-apparaat stuurt een signaal wanneer een noot wordt ingedrukt en nog een wanneer ze wordt losgelaten. In de vorige post was dat rechttoe rechtaan: elke
knop speelde twee noten met een octaaf ertussen en er was geen overlap tussen knoppen. Wanneer een knop wordt ingedrukt, 
kunnen de bijbehorende noten dus starten; wanneer de knop wordt losgelaten, kunnen die noten weer worden gestopt. Eenvoudig...

![Nu is elke knop aan vier akkoorden gekoppeld, afhankelijk van welke modificatietoetsen zijn ingedrukt](/assets/posts/2021-12-16-MIDIpad_update/midipad_button_mapping.jpg)

Wanneer we echte akkoorden aan knoppen toewijzen, wordt het ingewikkelder. Stel je een toets voor die een C-akkoord speelt: zodra je erop drukt, wordt een signaal
verstuurd om de noten C, E en G te spelen. Wanneer je de toets loslaat, is een signaal nodig om die noten te stoppen. Maar als je zonder de eerste los te laten op een andere 
toets drukt die een E-akkoord (E-G#-Bb) speelt, overlapt er een noot. Bij het 
loslaten van de knop voor het C-akkoord mag de E-noot dus **niet** stoppen. Daarvoor moeten we enkele zaken bijhouden: 
welke modificatietoetsen actief waren toen een knop werd ingedrukt en welke noten momenteel spelen. Zo kunnen we op elk 
moment bepalen welke noten moeten spelen en welke moeten stoppen. Dat brengt wat extra verwerking met zich mee, 
maar gelukkig heeft de RP2040-chip ruim voldoende kracht om dit zonder veel moeite te doen.

Hoe je het toetsenblok bouwt, wordt [hier]({% post_url nl/2021/2021-04-05-Macropad %}) besproken. Die post bevat een onderdelenlijst, 
alle benodigde schema's en STL-bestanden voor de 3D-geprinte onderdelen. Als MIDI-apparaten nieuw voor je zijn, kun je beter
beginnen met de [vorige post]({% post_url nl/2021/2021-05-20-MIDIpad %}), omdat die een toegankelijker vertrekpunt biedt.

## MIDIPad v2.0 - de code

Hieronder staat de volledige code, die je ook [hier](./assets/posts/2021-12-16-MIDIpad_update/midapad_2.py) kunt downloaden. Ze is bedoeld voor [CircuitPython] 
en vereist dat de [AdaFruit MIDI]-bibliotheek op het apparaat is geïnstalleerd. Na de code licht ik enkele belangrijke wijzigingen
toe. Dit bestand moet worden hernoemd naar ```code.py``` en in de hoofdmap van de Pi Pico worden geplaatst.

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

## Modificatietoetsen toevoegen

Twee knoppen worden als modificatietoets gebruikt en worden in de programmalogica nu anders behandeld dan gewone 
knoppen die noten spelen. Er zijn nog enkele wijzigingen nodig om elke knop correct aan de juiste
led te blijven koppelen. Daarom definiëren we zowel een lijst met pinnen voor de knoppen als een lijst met de index van
de bijbehorende led. Hetzelfde doen we voor de modificatietoetsen.

```python
# Configuration, which LED pins are used, which buttons, how buttons map to notes
led_pins = [board.GP18,board.GP17,board.GP16,board.GP21,board.GP20,board.GP19, board.GP27, board.GP26,board.GP22]
button_pins = [board.GP13,board.GP14,board.GP15, board.GP10,board.GP11,board.GP12,board.GP7]
button_led_ix = [0,1,2,3,4,5,6]

modifier_pins = [board.GP8,board.GP9]
modifier_led_ix = [7, 8]
```

Om deze aanpassingen mogelijk te maken, waren doorheen de code nog enkele wijzigingen nodig. Niets al te ingewikkelds: de 
modificatietoetsen moeten afzonderlijk worden ingesteld en wanneer de *duty cycle* van een bepaalde led verandert, moet de index uit
```button_led_ix``` of ```modifier_led_ix``` worden gebruikt omdat toetsen en leds niet langer één-op-één gekoppeld zijn.

De modificatietoetsen gebruiken een oud trucje. Elke modificatietoets krijgt in essentie een waarde die
een macht van twee is: de eerste is 1 (2^0), de volgende 2 (2^1), daarna 4 (2^2), enzovoort. Tel je de waarden van alle 
ingedrukte modificatietoetsen op, dan krijg je voor elke mogelijke combinatie een uniek getal. Hier zijn slechts twee knoppen beschikbaar,
dus kan de modificatiewaarde 0 (geen modificatietoets), 1 (eerste knop ingedrukt), 2 (tweede knop ingedrukt) of 3 (beide knoppen 
ingedrukt) zijn. Dat gebeurt in het stukje code hieronder en vormt de eerste stap van de hoofdlus.

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

## Akkoorden spelen

De grootste hindernis bij het spelen van akkoorden is dat noten uit verschillende akkoorden kunnen overlappen. De logica om
bepaalde noten te starten en te stoppen moest dus worden uitgebreid.

In de vorige versie hielden we bij welke toetsen ingedrukt waren (zodat we ze correct konden loslaten) en of de noten 
die bij een toets hoorden al speelden, oftewel geactiveerd waren. Nu moeten we ook bijhouden welke modificatietoetsen 
actief waren toen een toets werd geactiveerd. In plaats van booleaanse logica stellen we de trigger daarom in op -1 (niet geactiveerd) of op de
modificatiewaarde (0-3) wanneer een knop wordt ingedrukt. 

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

## Welke akkoorden kies je en hoe definieer je ze?

Het korte antwoord: je voegt de akkoorden toe die je nodig hebt. Uit een majeurtoonladder koos ik de majeurakkoorden (C, D, E, F, G, A 
en B); met de modificatietoetsen kun je daar mineur-, sus2- of sus4-akkoorden van maken. Ze worden gedefinieerd in
een dictionary aan het begin van de code, ```note_mapping```. De sleutel is de actieve modificatietoets en de
waarde is een lijst met akkoorden die overeenkomt met de gedefinieerde knoppen.

De akkoorden aan je voorkeuren aanpassen is bijzonder eenvoudig. Voeg gewoon noten toe aan deze lijst, verwijder ze of wijzig ze, 
en klaar!

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

## Conclusie

De MIDIpad kan nu 28 verschillende akkoorden spelen, een flinke toename tegenover de 9 uit de vorige versie. Ook
worden overlappende noten tussen akkoorden nu correct afgehandeld. Met een beetje extra moeite kan het kleine toetsenblok dus plots
een paar nieuwe trucjes. Er blijft wel een probleem met gewone schakelaars: die detecteren niet hoe hard een noot
wordt ingedrukt... Dat wil ik in een toekomstige post nog oplossen!

[CircuitPython]: https://circuitpython.readthedocs.io/
[AdaFruit MIDI]: https://github.com/adafruit/Adafruit_CircuitPython_MIDI
