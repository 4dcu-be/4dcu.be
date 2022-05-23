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