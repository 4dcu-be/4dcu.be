---
layout: post
title:  "Better code for the MacroPad"
byline: "using decorators"
date:   2022-05-23 10:00:00
author: Sebastian Proost
categories: diy
tags:	raspberry-pi python mechanical-keyboard soldering electronics
cover:  "/assets/posts/2021-04-05-Macropad/macropad_finished.jpg"
thumbnail: "/assets/images/thumbnails/macropad.jpg"
---

A while ago I've made a [MacroPad] and I recently improved the code! In this post I'll briefly show some advanced code
to create a ```MacroPad``` class which allows custom functions to be added to key presses using a decorator. The
original code as well as instructions how to build one yourself can be found in the original post.

![Completed MacroPad](/assets/posts/2021-04-05-Macropad/macropad_finished2.jpg)

## Event based library

I got the idea for implementing this library from the [KeyBow 2040] that implements this specifically for their
hardware. This makes the code to actually program their keypad a lot less complex. You can see in the example below, 
that you simply write the function you want and add ```@keybow.on_press(key)``` above the function you want to run when
the ```key``` is pressed. Let's see if this can be ported to my [MacroPad].

```python
# Example code from the KeyBow 2040 GitHub Repo

@keybow.on_press(key)
def press_handler(key):
    key.led_on()
```

To achieve this a new library needs to be created that can set up the MacroPad, handle keystrokes and allow you to
 attach new functions to each key pressed. This is an advanced bit of code, and I won't go through each part step by
 step, but it is a great example how you can create a library with a class that allows users to mix in their own 
 functions that are triggered at specific point in the class' code. It will also handle the light effects so this
 doesn't need to be handled by the user.
 

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

This file needs to be saved as ```macropad.py``` (download it [here](/assets/posts/2022-05-23-Macropad_update/macropad.py))
and stored in the root directory of the Pi Pico powering the pad.

## Much cleaner code

With the library in place, we just need to create the ```code.py``` file that specifies what each button does. Like
 in the previous version, we'll emulate a keyboard and attach some shortcuts to each key.

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

Or in combination with the [Adafruit HID] library to emulate a keyboard. One caveat, using the decorator
in a loop can be tricky.

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

## My shortcuts

I assigned three buttons to shift between different virtual desktops and show the overview. As I currently have a 
 single screen (albeit a rather big one), being able to flip to another desktop with a single button provides an
 experience similar to having a dual-monitor setup. Potentially even better, as you can have distracting apps like your
 mail open in another virtual desktop and only switch when you feel like it. Incoming mail isn't screaming for 
 attention from the secondary screen. Ctrl + F4 closes a browser tab, while ctrl + F5 is a hard refresh
 of a web page (comes in useful when developing). 

The four other buttons I'm still trying to find a good purpose for, any suggestions ?

## Conclusion

While you might have worked with libraries that use decorators (e.g. Flask), setting this up yourself takes a bit of
thinking/tinkering. Though in this case going the extra mile to create a library that handles the key presses, so you
can focus on the code that needs to run when a button is pressed pays off.

[MacroPad]: {% post_url 2021/2021-04-05-Macropad %}
[KeyBow 2040]: https://www.tomshardware.com/reviews/pimoroni-keybow-2040-review-programmable-keyboard-with-pi-silicon-inside
[Adafruit HID]: https://github.com/adafruit/Adafruit_CircuitPython_HID
