// SerLedTestSPI.pde - SPI Interface Version for use with chipKIT UNO
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
//	Uses 5 pins:
//		+5v
//		GND
//		SS   (pin 10)
//		SDI  (pin 11) MOSI
//		SCK  (pin 13)
//
//	JP4 to RD4(left) so pin 10 is a regular output NOT SPI Slave Select since we are an SPI Master
//	JP5 & JP7 up to select SPI Master
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
#define	SEGHORZ		SEGA | SEGD | SEGG		// Bars top, middle, and bottom
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
void	SPIClear();			// Clear Display and set cursor to position 1
void	SPIMoveCursor(int);		// Position cursor to position 1-4 (0-3)
void	SPISetDots(int);		// Set decimal points, colon, or apostrophe
void	SPIClearDots(int);		// Clear decimal points, colon, or apostrophe
void	SPISetBrightness(int);		// Set display brightness
void	SPISetSeg(int, int);		// Set a digit segment
void	SPISetBaud(int);		// Set the baud rate
void	SPIFactoryReset();		// Reset the display to the factory defaults
void	SPIBlackStart();		// Recover from unknown baud rate
void	SPISendValue(int);		// Send an integer value to the display
void	SPISendString(char*);		// Send a 4 chacacter string to the display
void	SPISendChar(byte);		// Send 1 character to the display
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

#include <SPI.h>			// SPI Library

int csPin = 10;				// Chip Select pin definition
					// LOW selects, HIGH deselects

// Main Program

void	setup()
{
	pinMode(csPin, OUTPUT);
	digitalWrite(csPin, HIGH);	// Deselect the serial LED
	Serial.begin(9600);		// Start serial communications for debug messages
	Serial.println("Initialized SPI as Master");
	SPI.begin();			// Initialize the SPI hardware
	SPI.setClockDivider(SPI_CLOCK_DIV64);  // Slow down the SPI Master a bit
	SPIClear();			// Reset the LED display, cursor to position 1
	SPISetBrightness(255);		// set display to max brightness
	Serial.println("Reset the Serial LED Display");
}

void loop()
{
	Serial.println("Mainloop");
	tstValue(1234);			// Output 4 integer digits
	SPIMoveCursor(0);		// Reset cursor to position 1
	tstString("abcd");		// Output 4 ascii characters
	SPIMoveCursor(0);		// Reset cursor to position 1
	tstWrap();			// Output enough characters to wrap display
	SPIClear();			// Reset cursor to position 1
	tstDots();			// Cycle through all the dots
	tstSegs();			// Draw a box
	SPIMoveCursor(0);		// Reset cursor to position 1
	tstMove();			// Move the cursor right to left
	SPIMoveCursor(0);		// Reset cursor to position 1
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
	SPISendValue(val);
	delay(2000);
}

void	tstString(char* str)
{
	Serial.print("String: ");
	Serial.println(str);
	SPISendString(str);
	delay(2000);
}

void	tstDots()
{
	Serial.println("Dots....");
	SPISetDots(DOT1);
	delay(1000);
	SPISetDots(DOT2);
	delay(1000);
	SPISetDots(DOT3);
	delay(1000);
	SPISetDots(DOT4);
	delay(1000);
	SPISetDots(COLON);
	delay(1000);
	SPISetDots(APOSTROPHE);
	delay(1000);
	SPISetDots(DOTSOFF);
	delay(1000);
}

void	tstSegs()
{
	Serial.println("Segments...");
	SPISetSeg(DIGIT1, SEGLEFT);
	delay(1000);
	SPISetSeg(DIGIT2, SEGA | SEGD);
	delay(1000);
	SPISetSeg(DIGIT3, SEGA | SEGD);
	delay(1000);
	SPISetSeg(DIGIT4, SEGRIGHT);
	delay(1000);
}

void	tstBrightness(int level)
{
	Serial.print("Vary Brightness: ");
	Serial.println(level);
	SPISetBrightness(level);
	delay(2000);
}

void	tstMove()
{
	Serial.println("Move Cursor Right to Left...");
	SPIClear();
	delay(100);

	SPIMoveCursor(3);
	delay(100);
	SPISendChar('3');
	delay(1000);

	SPIMoveCursor(2);
	delay(100);
	SPISendChar('2');
	delay(1000);

	SPIMoveCursor(1);
	delay(100);
	SPISendChar('1');
	delay(1000);

	SPIMoveCursor(0);
	delay(100);
	SPISendChar('0');
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

void	SPIClear()			// Clear Display and set cursor to position 1
{
	digitalWrite(csPin, LOW);
	SPI.transfer(CLEARDISP);
	digitalWrite(csPin, HIGH);
}

void	SPIMoveCursor(int pos)		// Position cursor to position 1-4 (0-3)
{
	digitalWrite(csPin, LOW);
	SPI.transfer(CURSORPOS);
	SPI.transfer(pos);
	digitalWrite(csPin, HIGH);
}

void	SPISetDots(int dot)		// Set decimal points, colon, or apostrophe
{
	digitalWrite(csPin, LOW);
	SPI.transfer(DECIMALCMD);
	SPI.transfer(dot);
	digitalWrite(csPin, HIGH);
}

void	SPIClearDots(int dot)		// Clear decimal points, colon, or apostrophe
{
	digitalWrite(csPin, LOW);
	SPI.transfer(DECIMALCMD);
	SPI.transfer(!dot);
	digitalWrite(csPin, HIGH);
}

void	SPISetBrightness(int bright)	// Set display brightness
{
	digitalWrite(csPin, LOW);
	SPI.transfer(BRIGHTNESS);
	SPI.transfer(bright);
	digitalWrite(csPin, HIGH);
}

void	SPISetSeg(int digit, int code)	// Set a digit segment
{
	digitalWrite(csPin, LOW);
	SPI.transfer(digit);
	SPI.transfer(code);
	digitalWrite(csPin, HIGH);
}

void	SPISetBaud(int rate)		// Set the baud rate
{
	digitalWrite(csPin, LOW);
	SPI.transfer(BAUD);
	SPI.transfer(rate);
	digitalWrite(csPin, HIGH);
}

void	SPIFactoryReset()		// Reset the display to the factory defaults
{
	digitalWrite(csPin, LOW);
	SPI.transfer(RESETDISP);
	digitalWrite(csPin, HIGH);
}

void	SPIBlackStart()			// Recover from unknown baud rate - may only work via softserial
{
}	

void	SPISendValue(int val)		// Send an integer value to the display
{
	digitalWrite(csPin, LOW); 	// transmit to device #1
	SPI.transfer(val / 1000);	//Send the left most digit
	val %= 1000;			//Now remove the left most digit from the number we want to display
	SPI.transfer(val / 100);
	val %= 100;
	SPI.transfer(val / 10);
	val %= 10;
	SPI.transfer(val);		//Send the right most digit
	digitalWrite(csPin, HIGH);	//Stop SPI transmission
}

void	SPISendString(char *string)	// Send a 4 chacacter string to the display
{
	digitalWrite(csPin, LOW);	// transmit to device #1
	for(byte x = 0 ; x < strlen(string) ; x++)
	{
		SPI.transfer(string[x]);//Send a character from the array out over SPI
		delay(1);
	}
	digitalWrite(csPin, HIGH);	//Stop SPI transmission
}

void	SPISendChar(byte letter)
{
	digitalWrite(csPin, LOW);	// transmit to device #1
	SPI.transfer(letter);		//Send a character to current cursor position
	digitalWrite(csPin, HIGH);	//Stop SPI transmission
}

