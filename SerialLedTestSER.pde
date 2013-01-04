// SerLedTestSER.pde - Serial Interface Version for use with the chipKIT UNO
//
// Test file for the Sparkfun Serial LED used with the chipKIT UNO
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
//	Uses 3 Wires:
//		+5v
//		GND
//		TX  (pin 40-UART2)
//		uses UART2 so that UART1/USB can be used for debug messages
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

void	SERClear();			// Clear Display and set cursor to position 1
void	SERMoveCursor(int);		// Position cursor to position 1-4 (0-3)
void	SERSetDots(int);		// Set decimal points, colon, or apostrophe
void	SERClearDots(int);		// Clear decimal points, colon, or apostrophe
void	SERSetBrightness(int);		// Set display brightness
void	SERSetSeg(int, int);		// Set a digit segment
void	SERSetBaud(int);		// Set the baud rate
void	SERFactoryReset();		// Reset the display to the factory defaults
void	SERBlackStart();		// Recover from unknown baud rate
void	SERSendValue(int);		// Send an integer value to the display
void	SERSendString(char*);		// Send a 4 chacacter string to the display
void	SERSendChar(byte);		// Send 1 character to the display
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

// Main Program

void	setup()
{
	Serial.begin(9600);		// Start serial communications for debug messages
	Serial.println("Initialized Serial as Master");
	Serial1.begin(9600);		// Initialize the UART1 hardware
	SERClear();			// Reset the LED display, cursor to position 1
	SERSetBrightness(255);		// set display to max brightness
	Serial.println("Reset the Serial LED Display");
}

void loop()
{
	Serial.println("Mainloop");
	tstValue(1234);			// Output 4 integer digits
	SERMoveCursor(0);		// Reset cursor to position 1
	tstString("abcd");		// Output 4 ascii characters
	SERMoveCursor(0);		// Reset cursor to position 1
	tstWrap();			// Output enough characters to wrap display
	SERClear();			// Reset cursor to position 1
	tstDots();			// Cycle through all the dots
	tstSegs();			// Draw a box
	SERMoveCursor(0);		// Reset cursor to position 1
	tstMove();			// Move the cursor right to left
	SERMoveCursor(0);		// Reset cursor to position 1
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
	SERSendValue(val);
	delay(2000);
}

void	tstString(char* str)
{
	Serial.print("String: ");
	Serial.println(str);
	SERSendString(str);
	delay(2000);
}

void	tstDots()
{
	Serial.println("Dots....");
	SERSetDots(DOT1);
	delay(1000);
	SERSetDots(DOT2);
	delay(1000);
	SERSetDots(DOT3);
	delay(1000);
	SERSetDots(DOT4);
	delay(1000);
	SERSetDots(COLON);
	delay(1000);
	SERSetDots(APOSTROPHE);
	delay(1000);
	SERSetDots(DOTSOFF);
	delay(1000);
}

void	tstSegs()
{
	Serial.println("Segments...");
	SERSetSeg(DIGIT1, SEGLEFT);
	delay(1000);
	SERSetSeg(DIGIT2, SEGA | SEGD);
	delay(1000);
	SERSetSeg(DIGIT3, SEGA | SEGD);
	delay(1000);
	SERSetSeg(DIGIT4, SEGRIGHT);
	delay(1000);
}

void	tstBrightness(int level)
{
	Serial.println("Vary Brightness...");
	SERSetBrightness(level);
	delay(2000);
}

void	tstMove()
{
	Serial.println("Move Cursor Right to Left...");
	SERClear();
	delay(100);

	SERMoveCursor(3);
	delay(100);
	SERSendChar('3');
	delay(1000);

	SERMoveCursor(2);
	delay(100);
	SERSendChar('2');
	delay(1000);

	SERMoveCursor(1);
	delay(100);
	SERSendChar('1');
	delay(1000);

	SERMoveCursor(0);
	delay(100);
	SERSendChar('0');
	delay(1000);
}

void	tstWrap()
{
	tstString("1234");
	tstString("56");
}

// Library Subroutines

void	SERClear()			// Clear Display and set cursor to position 1
{
	Serial1.write(CLEARDISP);
}

void	SERMoveCursor(int pos)		// Position cursor to position 1-4 (0-3)
{
	Serial1.write(CURSORPOS);
	Serial1.write(pos);
}

void	SERSetDots(int dot)		// Set decimal points, colon, or apostrophe
{
	Serial1.write(DECIMALCMD);
	Serial1.write(dot);
}

void	SERClearDots(int dot)		// Clear decimal points, colon, or apostrophe
{
	Serial1.write(DECIMALCMD);
	Serial1.write(!dot);
}

void	SERSetBrightness(int bright)	// Set display brightness
{
	Serial1.write(BRIGHTNESS);
	Serial1.write(bright);
}

void	SERSetSeg(int digit, int code)	// Set a digit segment
{
	Serial1.write(digit);
	Serial1.write(code);
}

void	SERSetBaud(int rate)		// Set the baud rate
{
	Serial1.write(BAUD);
	Serial1.write(rate);
}

void	SERFactoryReset()		// Reset the display to the factory defaults
{
	Serial1.write(RESETDISP);
}

void	SERBlackStart()			// Recover from unknown baud rate - may only work via serial
{
	int BaudRates[12] = {2400, 4800, 9600, 14400, 19200,
			    38400, 57600, 76800, 115200,
			    250000, 500000, 1000000};
	for(int i=0; i<12; i++)
	{
		Serial1.begin(BaudRates[i]);
		delay(10);
		SERFactoryReset();
	}
	Serial1.begin(9600);
	delay(10);
	SERClear();
	SERSendString("test");
}	

void	SERSendValue(int val)		// Send an integer value to the display
{
	Serial1.write(val / 1000);	//Send the left most digit
	val %= 1000;			//Now remove the left most digit from the number we want to display
	Serial1.write(val / 100);
	val %= 100;
	Serial1.write(val / 10);
	val %= 10;
	Serial1.write(val);		//Send the right most digit
}

void	SERSendString(char *string)	// Send a 4 chacacter string to the display
{
	for(byte x = 0 ; x < strlen(string) ; x++)
	{
		Serial1.write(string[x]);//Send a character from the array out over UART1
		delay(1);
	}
}

void	SERSendChar(byte letter)
{
	Serial1.write(letter);		//Send a character to current cursor position
}

