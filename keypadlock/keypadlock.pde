// include the atmel I2C libs
#include "mpr121.h"
#include "i2c.h"
#include <Servo.h>

int irqpin = 2; // Keypad pin
int green_led = 7;
int red_led = 6;
int servo_pin = 9;

Servo servo;
int servo_pos = 5;

// 11 max digits used
#define DIGITS 11 

// Match key inputs with electrode numbers
#define ONE 8
#define TWO 5
#define THREE 2
#define FOUR 7
#define FIVE 4
#define SIX 1
#define SEVEN 6
#define EIGHT 3
#define NINE 0

//extras (not used)
#define ELE9 9
#define ELE10 10
#define ELE11 11

int pin[4] = {9, 6, 2, 8};
int key_log[4] = {0,0,0,0};
unsigned long led_on_time = 0L;
unsigned long led_on_delay = 0L;

void setup()
{
	// Setup the LEDs with the red one.
	pinMode(green_led, OUTPUT);
	pinMode(red_led, OUTPUT);
	digitalWrite(green_led, LOW);
	digitalWrite(green_led, LOW);
	// Setup the Servo to lock position (0)
  servo.attach(9);
  servo.write(servo_pos);

  //make sure the interrupt pin is an input and pulled high
  pinMode(irqpin, INPUT);
  digitalWrite(irqpin, HIGH);
  
  //configure serial out
  Serial.begin(9600);
  
  //output on ADC4 (PC4, SDA)
  DDRC |= 0b00010011;
  // Pull-ups on I2C Bus
  PORTC = 0b00110000; 
  // initalize I2C bus. Wiring lib not used. 
  i2cInit();
  
  delay(100);
  // initialize mpr121
  mpr121QuickConfig();
  
  // Create and interrupt to trigger when a button
  // is hit, the IRQ pin goes low, and the function getNumber is run. 
  attachInterrupt(0,getNumber,LOW);
  
  // prints 'Ready...' when you can start hitting numbers
  Serial.println("Ready...");
}

void loop()
{
	if (led_on_delay > 0) {
		//You can put additional code here. The interrupt will run in the backgound. 
		unsigned long current_time = millis();
		if (led_on_time + led_on_delay < current_time) {
			digitalWrite(red_led, LOW);
			digitalWrite(green_led, LOW);
			led_on_delay = 0;
		}
  }
}

void advanceLog(int number) {
	for (int ii = 1; ii < 4; ++ii) {
		key_log[ii-1] = key_log[ii];
	}
	key_log[3] = number;
	
	Serial.println("Simdiye kadar girilen:");
	Serial.print(char(48+key_log[0]));
	Serial.print(char(48+key_log[1]));
	Serial.print(char(48+key_log[2]));
	Serial.println(char(48+key_log[3]));
}

void moveServo(int angle){
	servo.write(angle);
	servo_pos = angle;
}

bool isLogEqualToPin() {
	for (int ii = 0; ii < 4; ++ii) {
		if (key_log[ii] != pin[ii]) {
			Serial.print("Sifrenin ");
			Serial.print(char(48+ii));
			Serial.println("inci hanesi yanlis.");
			return false;
		}
	}
	Serial.println("Sifre dogru.");
	return true;
}

void blink(int led, unsigned long delay) {
	led_on_time = millis();
	led_on_delay = delay;
  digitalWrite(led, HIGH);
}

void getNumber()
{
  int i = 0;
  int touchNumber = 0;
  uint16_t touchstatus;
  int number = 0;
  touchstatus = mpr121Read(0x01) << 8;
  touchstatus |= mpr121Read(0x00);
  
  for (int j=0; j<12; j++)  // Check how many electrodes were pressed
  {
    if ((touchstatus & (1<<j)))
      touchNumber++;
  }
  
  if (touchNumber == 1)
  {
    if (touchstatus & (1<<SEVEN))
      number = 7;
    else if (touchstatus & (1<<FOUR))
      number = 4;
    else if (touchstatus & (1<<ONE))
      number = 1;
    else if (touchstatus & (1<<EIGHT))
      number = 8;
    else if (touchstatus & (1<<FIVE))
      number = 5;
    else if (touchstatus & (1<<TWO))
      number = 2;
    else if (touchstatus & (1<<NINE))
      number = 9;
    else if (touchstatus & (1<<SIX))
      number = 6;
    else if (touchstatus & (1<<THREE))
      number = 3;

    Serial.print(char(48+number));
    advanceLog(number);
    if (isLogEqualToPin()) {
			blink(green_led, 500L);
	    moveServo(servo_pos == 5 ? 180 : 5);
		} else {
			blink(red_led, 100L);
		}
  }
  //do nothing if more than one button is pressed
  else if (touchNumber == 0)
    ;
  else
    ;
}
