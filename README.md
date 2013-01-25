arduino_keypad
==============

Simple keypad code for arduino with funcitoning servo as lock:
WARNING: This ver basic code for a POC. There are huge security holes so do not use this on your front door. You have been warned.




SETUP
=====
//make sure your inputs and outputs are aligned , modify code below

int irqpin = 2; // Keypad pin

int green_led = 7;

int red_led = 6;

int servo_pin = 9;


Servo servo;

int servo_pos = 5;


//Set your passcode : )
int pin[4] = {9, 6, 2, 8};


HARDWARE REQUIREMENTS:
======================
Make sure you have the following hardware
- keypad: https://www.sparkfun.com/products/10508
- Tiny servo
- breadboard
- connection wires. 
- (optional) leds for indicators

Enjoy
Alp
- Optional 



