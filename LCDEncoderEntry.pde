// DataSelectionTest.pde - Uses Rotary Encoder and 2-line LCD Display
//                         to prompt for and input data
//
// Displays a starting value and updates this value when the encoder changes
// Push the encoder switch to select the current encoder value
//
// LCD uses UART1 pin 40 to free up UART0 pins 0/1 for debug messages
//
// Last modified: 1/4/2013 by James M. Lynes, Jr.
//
// This code is public domain, but you can buy me a beer(or Dr. Pepper)
// if you use this and we meet some day(Beerware License).
//
//
// Constant Definitions
//
// Display Commands
//
#define	COMMAND		0xFE		// Command Code
#define	CLEARDISP	0x01		// Clear the display
#define	CURSORHOME	0x02		// Send the cursor home
#define	CURSORRIGHT	0x14		// Move the cursor right one position
#define	CURSORLEFT	0x10		// Move cursor left one position
#define	SCROLLRIGHT	0x1C		// Scroll the display right
#define	SCROLLLEFT	0x18		// Scroll the display left
#define	DISPLAYON	0x0C		// Turn the display on
#define DISPLAYOFF	0x08		// Turn the display off
#define	UCURSORON	0x0E		// Turn underline cursor on
#define UCURSOROFF	0x0C		// Turn underline cursor off
#define	BOXCURSORON	0x0D		// Turn box cursor on
#define	BOXCURSOROFF	0x0C		// Turn box cursor off
#define	LINE1		0x80		// Row 1 COl 1 Address
#define	LINE2		0xC0		// Row 2 COl 1 Address
#define	RESET		0x12		// Reset code, send at 9600 baud immediately after POR
//
// Configuration Commands
//
#define	CONFIG		0x7C		// Configuration Code
#define	B2400		0x0B		// Set 2400  baud
#define B4800		0x0C		// Set 4800  baud
#define	B9600		0x0D		// Set 9600  baud
#define B144K		0x0E		// Set 14400 baud
#define	B192K		0x0F		// Set 19200 baud
#define B384K		0x10		// Set 38400 baud
#define SAVESPLASH	0x0A		// Save a new splash message
#define	TOGGLESPLASH	0x09		// Toggle splash screen on and off
#define	BACKLIGHTOFF	0x80		// Turn the backlight off
#define	BACKLIGHTMED	0x8F		// Turn the backlight to 50%
#define BACKLIGHTHIGH	0x9D		// Turn the backlight to 100%
//
// Misc Defines
//
#define	LCDTYPE		0x03		// Type 2 line x 16 characters
#define	LCDDelay	0x10		// General delay timer
#define	LCDDelay2	0x200		// Scroll timer
//
// Function Protypes
//
void	LCDClear();			// Clear the display
void	LCDSelectLineOne();		// Position cursor to the beginning of line 1
void	LCDSelectLineTwo();		// Position cursor to the beginning of Line 2
void	LCDGoTo(int position);		// Position cursor to a specific character 0-15, 16-31
void	LCDBacklightOn();		// Turn the backlight on
void	LCDBacklightOff();		// Turn the backlight off
void	LCDCursorHome();		// Position cursor to home
void	LCDCursorRight();		// Set cursor to move left to rght
void	LCDCursorLeft();		// Set cursor to move right to left
void	LCDScrollRight();		// Scroll the display right
void	LCDScrollLeft();		// Scroll the dispaly left
void	LCDDisplayOn();			// Turn the display on
void	LCDDisplayOff();		// Turn the display off
void	LCDUCursorOn();			// Turn the underline cursor on
void	LCDUCursorOff();		// Turn the underline cursor off
void	LCDBoxCursorOn();		// Turn the box cursor on
void	LCDBoxCursorOff();		// Turn the box cousor off
void	LCDBlackStart();		// Restart from an unknown state
void	LCDSaveSplash(char*, char*);	// Save a new spash display
void	LCDToggleSplash();		// Toggle the splash display on/off/on
void	LCDSetBrightness(int);		// Set the screen brightness 128-157(0x80-0x9D)
void	LCDSetBaud(int);		// Set a new baud rate
//
// Application Function Prototypes
//
void	prompt(char*, int);		// Prompt for user input
void	update(int);			// Update the value on line 2
void    encoderChanged();               // Test for encoder value changed
boolean switchPressed();                // Test for select switch pressed

#include <ChangeNotification.h>
//
// Pin Definitions
//
#define swtch         3			// Pin 3 Rotary Encoder shaft switch(w/hardware debounce)
#define redLed        5			// Pin 5 Rotary Encoder red shaft LED
#define greenLed      6			// Pin 6 Rotary Encoder green shaft LED
#define encoderPin1   14                // Pin 14 / A0 / CN_4
#define encoderPin2   15                // Pin 15 / A1 / CN_6

int oldnumber;
volatile int number;                    // used in both interrupt routines
volatile boolean halfleft = false;      // Used in both interrupt routines
volatile boolean halfright = false;     // Used in both interrupt routines

static int state = 1;                   // State Machine Pointer

//
// System Initialization
//
void setup() {

  Serial.begin(9600);					// Start serial communications for debug messages
  Serial.println("Initialized UNO Serial/USB Port");

  Serial1.begin(9600);					// Initialize the UART1 hardware - LCD Interface
  Serial.println("Initialized UNO UART1");

  LCDClear();						// Reset the LED display, cursor to position 1
  Serial.println("Cleared the LCD Display");

  LCDSetBrightness(BACKLIGHTHIGH);			// Set display to max brightness
  Serial.println("LCD Backlight to Max");

  pinMode(swtch, INPUT);				// with external pull-up and cap
  pinMode(redLed, OUTPUT);				// Red LED
  pinMode(greenLed, OUTPUT);				// Green LED

  pinMode(encoderPin1, INPUT);
  digitalWrite(encoderPin1, HIGH);               	// Turn on internal pullup resistor
  pinMode(encoderPin2, INPUT);
  digitalWrite(encoderPin2, HIGH);                	// Turn on internal pullup resistor

  attachInterrupt(CN_4, isr_A, FALLING);   		// Call isr_2 when digital pin 2 goes LOW
  attachInterrupt(CN_6, isr_B, FALLING);   		// Call isr_3 when digital pin 3 goes LOW
  Serial.println("ISR Started");
  
  digitalWrite(redLed, LOW);			        // Green for input enabled
  digitalWrite(greenLed, HIGH);
}
//
// Main Program
//
void loop() {
//
// State Machine to request data from the user
// Two cases per input value - Prompt and Input
//
switch(state) {
    case 1:   
            prompt("Enter 1st Value", 1000);
            state++;
            break;
    case 2:
            encoderChanged();
            if(switchPressed()) {
                Serial.println(number);
                state++;
            }
            break;
    case 3:   
            prompt("Enter 2nd Value", 20);
            state++;
            break;
    case 4:
            encoderChanged();
            if(switchPressed()) {
                Serial.println(number);
                state++;
            }
            break;
     default: {state = 1;}                              // Loop back to 1st prompt for testing
    }
}
//
// Application Functions
//
// Display user prompt
void	prompt(char *pstring, int dispVal ) {		// Prompt for user input, display starting value
	LCDClear();
	LCDSelectLineOne();
	Serial1.print(pstring);
        number = dispVal;                              // Initialize the encoder counters
        oldnumber = dispVal;
	update(dispVal);
        digitalWrite(redLed, LOW);			// Green for input enabled
        digitalWrite(greenLed, HIGH);
}
// Rewrite line 2 of display
void	update( int newDispVal ) {			// Update the value on line 2
	LCDSelectLineTwo();
        Serial1.print("                ");              // Clear line 2 before updating value
	LCDSelectLineTwo();
	Serial1.print(newDispVal);
}
// Test for encoder change
void    encoderChanged() {
        if(number != oldnumber) {              		// Change in value ?
            update(number);				// Update the screen
            oldnumber = number;
            digitalWrite(redLed, LOW);			// Green for encoding
            digitalWrite(greenLed, HIGH);
        }
}
// Test for encoder switch pressed
boolean switchPressed() {
        if(digitalRead(swtch) == LOW) {
            digitalWrite(redLed, HIGH);		        // Red for Selected
            digitalWrite(greenLed, LOW);
            Serial.println("Select...");
            delay(200);                                 // Delay 200ms to get your finger off the switch
            return true;
        }
return false;
}
//
// Interrupt Service Routines
//
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

//
// LCD Library Functions
//
void	LCDClear()
{
	Serial1.write(COMMAND);
	Serial1.write(CLEARDISP);		// Clear the display
	delay(LCDDelay);
}

void	LCDSelectLineOne()
{
	Serial1.write(COMMAND);
	Serial1.write(LINE1);			// Select line 1
	delay(LCDDelay);	
}

void	LCDSelectLineTwo()
{
	Serial1.write(COMMAND);
	Serial1.write(LINE2);			// Select line 2
	delay(LCDDelay);
}

void	LCDGoTo(int position)
{
	if(position < 16)			// Go to specific position 0-31
	{
		Serial1.write(COMMAND);
		Serial1.write(position + 128);
	}
	else if(position < 32)
	{
		Serial1.write(COMMAND);
		Serial1.write(position + 48 + 128);
	}
	else
	{
		LCDGoTo(0);
	}
	delay(LCDDelay);
}

void	LCDBacklightOn()
{
	Serial1.write(CONFIG);
	Serial1.write(BACKLIGHTHIGH);		// Turn the backlight on
	delay(LCDDelay);
}

void	LCDBacklightOff()
{
	Serial1.write(CONFIG);
	Serial1.write(BACKLIGHTOFF);		// Turn the backlight off
	delay(LCDDelay);
}

void	LCDCursorHome()
{
	Serial1.write(COMMAND);
	Serial1.write(CURSORHOME);		// Position the cursor to home
	delay(LCDDelay);
}

void	LCDCursorRight()
{
	Serial1.write(COMMAND);
	Serial1.write(CURSORRIGHT);		// Move cursor right one position
	delay(LCDDelay);
}

void	LCDCursorLeft()
{
	Serial1.write(COMMAND);
	Serial1.write(CURSORLEFT);		// Move cursor left one position
	delay(LCDDelay);
}

void	LCDScrollRight()
{
	Serial1.write(COMMAND);
	Serial1.write(SCROLLRIGHT);		// Scroll the display right one position
	delay(LCDDelay2);
}

void	LCDScrollLeft()
{
	Serial1.write(COMMAND);
	Serial1.write(SCROLLLEFT);		// Scroll the display left one position
	delay(LCDDelay2);
}

void	LCDDisplayOn()
{
	Serial1.write(COMMAND);
	Serial1.write(DISPLAYON);		// Turn the display on
	delay(LCDDelay);
}

void	LCDDisplayOff()
{
	Serial1.write(COMMAND);
	Serial1.write(DISPLAYOFF);		// Turn the display off
	delay(LCDDelay);
}

void	LCDUCursorOn()
{
	Serial1.write(COMMAND);
	Serial1.write(UCURSORON);		// Turn the underline cursor on
	delay(LCDDelay);
}

void	LCDUCursorOff()
{
	Serial1.write(COMMAND);
	Serial1.write(UCURSOROFF);		// Turn the underline cursor off
	delay(LCDDelay);
}

void	LCDBoxCursorOn()
{
	Serial1.write(COMMAND);
	Serial1.write(BOXCURSORON);		// Turn the box cursor on
	delay(LCDDelay);
}

void	LCDBoxCursorOff()
{
	Serial1.write(COMMAND);
	Serial1.write(BOXCURSOROFF);		// Turn the box cursor off
	delay(LCDDelay);
}

void	LCDBlackStart()
{
	Serial1.write(RESET);			// Restart from unknown condition
	delay(LCDDelay);
}

void	LCDSaveSplash(char *l1, char *l2)
{
	LCDSelectLineOne();			// Replace the splash screen
	Serial1.print(l1);
	LCDSelectLineTwo();
	Serial1.print(l2);
	Serial1.write(CONFIG);
	Serial1.write(SAVESPLASH);
	delay(LCDDelay);
}

void	LCDToggleSplash()
{
	Serial1.write(CONFIG);			// Toggle the splash screen on/off/on
	Serial1.write(TOGGLESPLASH);
	delay(LCDDelay);
}

void	LCDSetBrightness(int level)
{
	Serial1.write(CONFIG);			// Change the brightness level
	Serial1.write(level);
	delay(LCDDelay);
}

void	LCDSetBaud(int rate)
{
	Serial1.write(CONFIG);			// Change the baud rate
	Serial1.write(rate);
	delay(LCDDelay);
}
