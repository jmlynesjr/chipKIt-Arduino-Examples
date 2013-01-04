// SerLedTestI2C.pde - I2C Interface Version for use with the chipKIT UNO
//
// Test file for the Sparkfun Serial LED
//    Combined header and library files for initial testing of the display.
//    Hope to split into a library after testing.
//
// James M. Lynes, Jr.
// Last Modified: December 24,2012
//
// Adapted from code examples and documentation written by Nathan Seidle of Sparkfun Electronics
// This code is public domain, but you buy me(or Nathan) a beer
// if you use this and we meet some day(Beerware License).
//
//	Uses 4 wires:
//		+5v
//		Gnd
//		SDA(pin 18/A4)
//		SCL(pin 19/A5)
//
//	JP6 & JP8 to RG2(down) position to select I2C rather than A4/A5
//
// Constant Definitions
//
#define	I2CADD		0x71		// Default I2C address
#define	CURSORPOS	0x79		// 0-3
#define	CLEARDISP	0x76		// None
#define	DECIMALCMD	0x77		// 0-63
#define	BRIGHTNESS	0x7A		// 0-255
#define DIGIT1		0x7B		// 0-127
#define	DIGIT2		0x7C		// 0-127
#define	DIGIT3		0x7D		// 0-127
#define	DIGIT4		0x7E		// 0-127
#define	BAUD		0x7F		// 0-11
#define	I2CADDCFG	0x80		// 1-126
#define	RESETDISP	0x81		// None
#define	SEGA		0x01		// None
#define	SEGB		0x02		// None
#define	SEGC		0x04		// None
#define	SEGD		0x08		// None
#define	SEGE		0x10		// None
#define	SEGF		0x20		// None
#define	SEGG		0x40		// None
#define	SEGLEFT		SEGA | SEGD | SEGE | SEGF	// Bar on left
#define	SEGRIGHT	SEGA | SEGB | SEGC | SEGD	// Bar on right
#define	SEGHORZ		SEGA | SEGD | SEGG	// Bars top, middle, and bottom
#define	B2400		0x00		// 2400
#define	B4800		0x01		// 4800
#define	B9600		0x02		// 9600
#define	B144K		0x03		// 14400
#define	B192K		0x04		// 19200
#define	B384K		0x05		// 38400
#define	B576K		0x06		// 57600
#define	B768K		0x07		// 76800
#define	B1152K		0x08		// 115200
#define	B2500K		0x09		// 250000
#define	B5000K		0x0A		// 500000
#define	B1M		0x0B		// 1000000
#define	DOT1		0x01		// None
#define	DOT2		0x02		// None
#define	DOT3		0x04		// None
#define	DOT4		0x08		// None
#define	COLON		0x10		// None
#define	APOSTROPHE	0x20		// None
#define	DOTSOFF		0x00		// None
//
// Function Protypes
//
void	I2CClear();			// Clear Display and set cursor to position 1
void	I2CMoveCursor(int);		// Position cursor to position 1-4 (0-3)
void	I2CSetDots(int);		// Set decimal points, colon, or apostrophe
void	I2CClearDots(int);		// Clear decimal points, colon, or apostrophe
void	I2CSetBrightness(int);		// Set display brightness
void	I2CSetSeg(int, int);		// Set a digit segment
void	I2CSetBaud(int);		// Set the baud rate
void	I2CSetAddr(int);		// Change the default I2C address
void	I2CFactoryReset();		// Reset the display to the factory defaults
void	I2CBlackStart();		// Recover from unknown baud rate
void	I2CSendValue(int);		// Send an integer value to the display
void	I2CSendString(char*);		// Send a 4 character string to the display
void	I2CSendChar(byte);		// Send 1 character to the display
//
// Test Function Prototypes
//
void	tstValue(int);			// Output 4 integer digits
void	tstString(char*);		// Output 4 ascii characters
void	tstDots();			// Cycle through all the dots
void	tstSegs();			// Draw a box
void	tstBrightness(int);		// Cycle brightness - off, half, full
void	tstMove();			// Move cursor right to left
void	tstWrap();			// Output enough characters to wrap display

#include <Wire.h>			// I2C Library

// Main Program

void	setup()
{
	Wire.begin();			// Join I2C bus as master
	Serial.begin(9600);		// Start serial communications for debug messages
	delay(2000);			// Give the initialization time to complete
	Serial.println("Initialized I2C as Bus Master");
	I2CClear();			// Reset the LED display, set the cursor to position 1
	I2CSetBrightness(255);		// set display to max brightness
	Serial.println("Reset the Serial LED Display");
}

void loop()
{
	Serial.println("Mainloop");
	tstValue(1234);			// Output 4 integer digits
	I2CMoveCursor(0);		// Reset the cursor to position 1
	tstString("abcd");		// Output 4 ascii characters
	I2CMoveCursor(0);		// Reset the cursor to position 1
	tstWrap();			// Output 6 ascii characters to test wrap
	I2CClear();			// Reset cursor to position 1
	tstDots();			// Cycle through all the dots
	tstSegs();			// Draw a box
	I2CMoveCursor(0);		// Reset the cursor to position 1
	tstMove();			// Move the cursor right to left
	I2CMoveCursor(0);		// Reset the cursor to position 1
//	tstBrightness(0);		// Cycle brightness - off, half, full
//	tstBrightness(127);
//	tstBrightness(255);
	delay(1000);
}

// Test Subroutines

void	tstValue(int val)
{
	Serial.print("Value: ");
	Serial.println(val);
	I2CSendValue(val);
	delay(2000);
}

void	tstString(char* str)
{
	Serial.print("String: ");
	Serial.println(str);
	I2CSendString(str);
	delay(2000);
}

void	tstDots()
{
	Serial.println("Dots....");
	I2CSetDots(DOT1);
	delay(1000);
	I2CSetDots(DOT2);
	delay(1000);
	I2CSetDots(DOT3);
	delay(1000);
	I2CSetDots(DOT4);
	delay(1000);
	I2CSetDots(COLON);
	delay(1000);
	I2CSetDots(APOSTROPHE);
	delay(1000);
	I2CSetDots(DOTSOFF);
	delay(1000);
}

void	tstSegs()
{
	Serial.println("Segments...");
	I2CSetSeg(DIGIT1, SEGLEFT);
	delay(1000);
	I2CSetSeg(DIGIT2, SEGA | SEGD);
	delay(1000);
	I2CSetSeg(DIGIT3, SEGA | SEGD);
	delay(1000);
	I2CSetSeg(DIGIT4, SEGRIGHT);
	delay(1000);
}

void	tstBrightness(int level)
{
	Serial.print("Vary Brightness: ");
	Serial.println(level);
	I2CSetBrightness(level);
	delay(2000);
}

void	tstMove()
{
	Serial.println("Move Cursor Right to Left...");
	I2CClear();
	delay(100);

	I2CMoveCursor(3);
	delay(100);
	I2CSendChar('3');
	delay(1000);

	I2CMoveCursor(2);
	delay(100);
	I2CSendChar('2');
	delay(1000);

	I2CMoveCursor(1);
	delay(100);
	I2CSendChar('1');
	delay(1000);

	I2CMoveCursor(0);
	delay(100);
	I2CSendChar('0');
	delay(1000);
}

void	tstWrap()
{
	tstString("1234");
	delay(5);
	tstString("56");
	delay(1000);
}

// Library Subroutines

void	I2CClear()			// Clear Display and set cursor to position 1
{
	Wire.beginTransmission(I2CADD);
	Wire.send(CLEARDISP);
	Wire.endTransmission();
}

void	I2CMoveCursor(int pos)		// Position cursor to position 1-4 (0-3)
{
	Wire.beginTransmission(I2CADD);
	Wire.send(CURSORPOS);
	Wire.send(pos);
	Wire.endTransmission();
}

void	I2CSetDots(int dot)		// Set decimal points, colon, or apostrophe
{
	Wire.beginTransmission(I2CADD);
	Wire.send(DECIMALCMD);
	Wire.send(dot);
	Wire.endTransmission();
}

void	I2CClearDots(int dot)		// Clear decimal points, colon, or apostrophe
{
	Wire.beginTransmission(I2CADD);
	Wire.send(DECIMALCMD);
	Wire.send(!dot);
	Wire.endTransmission();
}

void	I2CSetBrightness(int bright)	// Set display brightness
{
	Wire.beginTransmission(I2CADD);
	Wire.send(BRIGHTNESS);
	Wire.send(bright);
	Wire.endTransmission();
}

void	I2CSetSeg(int digit, int code)	// Set a digit segment
{
	Wire.beginTransmission(I2CADD);
	Wire.send(digit);
	Wire.send(code);
	Wire.endTransmission();
}

void	I2CSetBaud(int rate)		// Set the baud rate
{
	Wire.beginTransmission(I2CADD);
	Wire.send(BAUD);
	Wire.send(rate);
	Wire.endTransmission();
}

void	I2CSetAddr(int addr)		// Change the default I2C address
{
	Wire.beginTransmission(I2CADD);
	Wire.send(I2CADDCFG);
	Wire.send(addr);
	Wire.endTransmission();
}

void	I2CFactoryReset()		// Reset the display to the factory defaults
{
	Wire.beginTransmission(I2CADD);
	Wire.send(RESETDISP);
	Wire.endTransmission();
}

void	I2CBlackStart()			// Recover from unknown baud rate - may only work via softserial
{
}	

void	I2CSendValue(int val)		// Send an integer value to the display
{
	Wire.beginTransmission(I2CADD); // transmit to device #1
	Wire.send(val / 1000);		//Send the left most digit
	val %= 1000;			//Now remove the left most digit from the number we want to display
	Wire.send(val / 100);
	val %= 100;
	Wire.send(val / 10);
	val %= 10;
	Wire.send(val);			//Send the right most digit
	Wire.endTransmission();		//Stop I2C transmission
}

void	I2CSendString(char *string)	// Send up to a 4 chacacter string to the display
{
	Wire.beginTransmission(I2CADD);	// transmit to device #1
	for(byte x = 0 ; x < strlen(string) ; x++)
	{
		Wire.send(string[x]);	//Send a character from the array out over I2C
	}
	Wire.endTransmission();		//Stop I2C transmission
}

void	I2CSendChar(byte letter)
{
	Wire.beginTransmission(I2CADD);	// transmit to device #1
	Wire.send(letter);		//Send a character to current cursor position
	Wire.endTransmission();		//Stop I2C transmission
}

