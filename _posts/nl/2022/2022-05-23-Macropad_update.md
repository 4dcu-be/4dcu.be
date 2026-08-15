---
layout: post
title:  "Betere code voor de MacroPad"
byline: "met decorators"
description: "De code van de zelfgemaakte MacroPad herwerken tot een nette Python-klasse die met decorators eigen functies aan toetsaanslagen koppelt, geïnspireerd door de KeyBow 2040."
date:   2022-05-23 10:00:00
author: Sebastian Proost
post_id: macropad-update
categories: diy
tags:	raspberry-pi python mechanical-keyboard soldering electronics
cover:  "/assets/posts/2021-04-05-Macropad/macropad_finished.jpg"
thumbnail: "/assets/images/thumbnails/macropad.jpg"
---

Een tijdje geleden maakte ik een [MacroPad] en onlangs heb ik de code verbeterd! In deze post toon ik kort wat
geavanceerde code om een ```MacroPad```-klasse te maken waarmee je via een decorator eigen functies aan toetsaanslagen
kunt koppelen. De oorspronkelijke code en de instructies om er zelf een te bouwen vind je in de originele post.

![Voltooide MacroPad](/assets/posts/2021-04-05-Macropad/macropad_finished2.jpg)

## Eventgestuurde bibliotheek

Het idee voor deze bibliotheek kreeg ik van de [KeyBow 2040], die dit specifiek voor zijn eigen hardware implementeert.
Daardoor wordt de code om hun toetsenblok daadwerkelijk te programmeren een stuk minder complex. In het onderstaande
voorbeeld zie je dat je gewoon de gewenste functie schrijft en ```@keybow.on_press(key)``` toevoegt boven de functie die
moet worden uitgevoerd wanneer ```key``` wordt ingedrukt. Eens kijken of ik dit naar mijn [MacroPad] kan overbrengen.

```python
# Example code from the KeyBow 2040 GitHub Repo

@keybow.on_press(key)
def press_handler(key):
    key.led_on()
```

Hiervoor moet een nieuwe bibliotheek worden gemaakt die de MacroPad kan instellen, toetsaanslagen kan verwerken en het
 mogelijk maakt om aan elke ingedrukte toets nieuwe functies te koppelen. Dit is een geavanceerd stukje code dat ik niet
 stap voor stap zal bespreken, maar het is een uitstekend voorbeeld van hoe je een bibliotheek kunt maken met een klasse
 waarin gebruikers hun eigen functies kunnen invoegen. Die worden dan op specifieke punten in de code van de klasse
 uitgevoerd. De bibliotheek regelt ook de lichteffecten, zodat de gebruiker dat zelf niet hoeft te doen.
 

{:.large-code}
```python
import board
import digitalio
import pwmio
import time

# Configuration, which LED pins are used, which buttons, how buttons map to macros
led_pins = [board.GP18,board.GP17,board.GP16,board.GP21,board.GP20,board.GP19, board.GP27, board.GP26,board.GP22]
button_pins = [board.GP13,board.GP14,board.GP15, board.GP10,board.GP11,board.GP12,board.GP7,board.GP8,board.GP9]

class Button(object):
    def __init__(self, button_index, button_pin, led_pin, repeat=True, repeat_time=0.075, first_repeat_time=0.5):
        self.number = button_index
        
        self.button = digitalio.DigitalInOut(button_pin)
        self.button.direction = digitalio.Direction.INPUT
        self.button.pull = digitalio.Pull.UP
        
        self.led = pwmio.PWMOut(led_pin, frequency=1000, duty_cycle=0)
        self.last_pressed = 0
        
        self.triggered = False
        
        self.on_press = None
        self.on_release = None
        
        self.repeat = repeat
        self.repeat_time = repeat_time
        self.first_repeat_time = first_repeat_time
        self.first_repeat = True
        
        self.time_of_last_press = time.monotonic()

    
    @property
    def pressed(self):
        return not self.button.value
    
    def set_duty_cycle(self, value):
        self.led.duty_cycle = value
    
    def fade(self, value=900):
        self.led.duty_cycle = max(self.led.duty_cycle - value, 0)
    
    def update(self):
        self.time_since_last_press = time.monotonic() - self.time_of_last_press
        
        if self.pressed and (not self.triggered or
                             (self.time_since_last_press > self.repeat_time and self.repeat and not self.first_repeat) or
                             (self.time_since_last_press > self.first_repeat_time and self.first_repeat and self.repeat)):
             
             self.time_of_last_press = time.monotonic()
             
             if self.time_since_last_press > self.first_repeat_time and self.first_repeat and self.triggered:
                 self.first_repeat = False
                 
             self.triggered = True
            
             self.set_duty_cycle(65025)
                 
             if self.on_press is not None:
                 self.on_press(self)
                
        elif self.triggered and not self.pressed:
            self.first_repeat = True
            self.triggered = False
            
            if self.on_release is not None:
                self.on_release(self)
                
        self.fade()

class Macropad(object):
    def __init__(self):
        print("Init Macropad")
        
        # Set up buttons
        self.buttons = []
        for ix, (bp, lp) in enumerate(zip(button_pins, led_pins)):
            self.buttons.append(Button(ix, bp, lp))
    
    def on_press(self, button, handler=None):
        if button is None:
            return
        
        def attach_handler(handler):
            button.on_press = handler

        if handler is not None:
            attach_handler(handler)
        else:
            return attach_handler
    
    def on_release(self, button, handler=None):
        if button is None:
            return
        
        def attach_handler(handler):
            button.on_release = handler

        if handler is not None:
            attach_handler(handler)
        else:
            return attach_handler
    
    def update(self):
        for btn in self.buttons:
            btn.update()
            
        time.sleep(0.01)
```

Dit bestand moet worden opgeslagen als ```macropad.py``` (download het [hier](/assets/posts/2022-05-23-Macropad_update/macropad.py))
en in de hoofdmap van de Pi Pico worden geplaatst die het toetsenbord aanstuurt.

## Veel nettere code

Nu de bibliotheek klaar is, hoeven we alleen nog het bestand ```code.py``` te maken waarin staat wat elke knop doet. Net
 als in de vorige versie bootsen we een toetsenbord na en koppelen we enkele sneltoetsen aan de verschillende knoppen.

```python
from macropad import Macropad
macropad = Macropad()
buttons = macropad.buttons

@macropad.on_press(buttons[0])
def press_first_button(button):
    print(f"pressed the first button")

@macropad.on_press(buttons[1])
def press_second_button(button):
    print(f"pressed the second button")
```

Of in combinatie met de [Adafruit HID]-bibliotheek om een toetsenbord na te bootsen. Eén kanttekening: een decorator
in een lus gebruiken kan lastig zijn.

{:.large-code}
```python
import usb_hid
from adafruit_hid.keyboard import Keyboard
from adafruit_hid.keycode import Keycode

from macropad import Macropad

keyboard = Keyboard(usb_hid.devices)

macropad = Macropad()
buttons = macropad.buttons

button_mapping = [
    [Keycode.LEFT_CONTROL, Keycode.WINDOWS, Keycode.LEFT_ARROW],
    [Keycode.WINDOWS, Keycode.TAB],
    [Keycode.LEFT_CONTROL, Keycode.WINDOWS, Keycode.RIGHT_ARROW],
    [Keycode.LEFT_CONTROL, Keycode.F4],
    [Keycode.LEFT_CONTROL, Keycode.F5],
    [Keycode.LEFT_CONTROL, Keycode.F6],
    [Keycode.LEFT_CONTROL, Keycode.F7],
    [Keycode.LEFT_CONTROL, Keycode.F8],
    [Keycode.LEFT_CONTROL, Keycode.F9]]

for btn in buttons:
    @macropad.on_press(btn)
    def press_button(button):
        print(f"pressed {button.number}")
        keyboard.press(*button_mapping[button.number])

    @macropad.on_release(btn)
    def release_button(button):
        print(f"released {button.number}")
        keyboard.release(*button_mapping[button.number])
    
while True:
    macropad.update()
```

## Mijn sneltoetsen

Ik heb drie knoppen toegewezen om tussen verschillende virtuele bureaubladen te wisselen en het overzicht te tonen.
Omdat ik momenteel maar één scherm heb (zij het een behoorlijk groot), geeft de mogelijkheid om met één druk op de knop
naar een ander bureaublad te gaan een ervaring die vergelijkbaar is met een opstelling met twee schermen. Mogelijk zelfs
beter, want je kunt afleidende apps zoals je mail op een ander virtueel bureaublad openzetten en alleen overschakelen
wanneer je daar zin in hebt. Binnenkomende mail schreeuwt zo niet voortdurend om aandacht op een tweede scherm. Ctrl + F4
sluit een browsertabblad, terwijl ctrl + F5 een webpagina volledig vernieuwt (handig tijdens het ontwikkelen).

Voor de vier andere knoppen zoek ik nog een goede toepassing. Iemand suggesties?

## Conclusie

Je hebt misschien al gewerkt met bibliotheken die decorators gebruiken (zoals Flask), maar om dit zelf op te zetten is
wat denk- en knutselwerk nodig. In dit geval loont het wel om een stap verder te gaan en een bibliotheek te maken die de
toetsaanslagen afhandelt. Zo kun je je concentreren op de code die moet worden uitgevoerd wanneer een knop wordt ingedrukt.

[MacroPad]: {% post_url nl/2021/2021-04-05-Macropad %}
[KeyBow 2040]: https://www.tomshardware.com/reviews/pimoroni-keybow-2040-review-programmable-keyboard-with-pi-silicon-inside
[Adafruit HID]: https://github.com/adafruit/Adafruit_CircuitPython_HID
