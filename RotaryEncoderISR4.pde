// RotaryEncoderISR4.pde  with Shaft Switch & R/G LED code

// Interrupt driven rotary encoder library for the chipKIT UNO
// Uses the Pin Change Library by Majenko from the chipKIT Forum
//          		http://sourceforge.net/projects/chipkitcn

// Uses Sparkfun Rotary Encoder - Illuminated(Red/Green) COM-10956
// and Sparkfun Rotary Encoder Breakout - Illuminated(Red/Green) BOB 10954

// Last Modified: 1/2/2013 James M. Lynes, Jr.

// The average rotary encoder has three pins, seen from front: A C B
// Clockwise rotation A(on)->B(on)->A(off)->B(off)
// CounterCW rotation B(on)->A(on)->B(off)->A(off)
// and maybe a push switch with another two pins and led backlights
// usually the rotary encoders three pins have the ground pin in the middle
  	
// Rotary encoder decoding using two interrupt lines.

// (Original Program sketch is for SparkFun Rotary Encoder sku: COM-09117)
// Adapted from code at: home.online.no/~togalaas/rotary_encoder
// Connect the middle pin of the three to ground.
// The outside two pins of the three are connected to
// digital pins 14 and 15


#include <ChangeNotification.h>

int swtch = 3;						// Rotary Encoder shaft switch
int redLed = 5;						// Rotary Encoder red shaft LED
int greenLed = 6;					// Rotary Encoder green shaft LED
int encoderPin1 = 14;                                   // Pin 14 / A0 / CN_4
int encoderPin2 = 15;                                   // Pin 15 / A1 / CN_6

volatile int number = 0;                		// Testnumber, print it when it changes value,
                                        		// used in loop and both interrupt routines
volatile boolean halfleft = false;      		// Used in both interrupt routines
volatile boolean halfright = false;      		// Used in both interrupt routines

int oldnumber = number;

void setup(){
  Serial.begin(9600);

  pinMode(swtch, INPUT);					// with external pull-up and cap
  pinMode(redLed, OUTPUT);				// Red LED
  pinMode(greenLed, OUTPUT);				// Green LED

  pinMode(encoderPin1, INPUT);
  digitalWrite(encoderPin1, HIGH);               	// Turn on internal pullup resistor
  pinMode(encoderPin2, INPUT);
  digitalWrite(encoderPin2, HIGH);                	// Turn on internal pullup resistor

  attachInterrupt(CN_4, isr_A, FALLING);   		// Call isr_2 when digital pin 2 goes LOW
  attachInterrupt(CN_6, isr_B, FALLING);   		// Call isr_3 when digital pin 3 goes LOW

  Serial.println("Starting Driver");
}

void loop(){
  if(number != oldnumber){              		// Change in value ?
    Serial.println(number);             		// Yes, print it (or whatever)
    oldnumber = number;
    digitalWrite(redLed, LOW);				// Green for encoding
    digitalWrite(greenLed, HIGH);
  }
  if(digitalRead(swtch) == LOW && number != 0) {        // Only process 1st reset push
    number = 0;
    oldnumber = 0;
    digitalWrite(redLed, HIGH);				// Red for Resetting
    digitalWrite(greenLed, LOW);
    Serial.println("Reset...");
  }
}

void isr_A(){                                           // A went LOW
  delay(3);                                             // Debounce time
                                                        // Trade off bounce vs missed counts
  int bits = PORTB;                                     // Atomic read of encoder inputs
  int LSB = (bits >> 2) & 0x01;
  int MSB = (bits >> 4) & 0x01;
  
  if(LSB == LOW){                              		// A still LOW ?
    if(MSB == HIGH && halfright == false){     		// -->
      halfright = true;                                 // One half click clockwise
    } 
    if(MSB == LOW && halfleft == true){        		// <--
      halfleft = false;                                 // One whole click counter-
      number--;                                         // clockwise
    }
  }
}
void isr_B(){                                           // B went LOW
  delay(3);                                             // Debounce time
                                                        // Trade off bounce vs missed counts
  int bits = PORTB;                                     // Atomic read of encoder inputs
  int LSB = (bits >> 2) & 0x01;
  int MSB = (bits >> 4) & 0x01;
  
  if(MSB == LOW){                              		// A still LOW ?
    if(LSB == HIGH && halfleft == false){     		// <--
      halfleft = true;                                  // One half  click counter-
    }                                                   // clockwise
    if(LSB == LOW && halfright == true){       		// -->
      halfright = false;                                // One whole click clockwise
      number++;
    }
  }
}
