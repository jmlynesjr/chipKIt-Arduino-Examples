// Rotary encoder read example - Polling Version
//
// Sparkfun Rotary Encoder - Illuminated(Red/Green) COM-10956
// Sparkfun Rotary Encoder Breakout - Illuminated(Red/Green) BOB 10954
//
// Last modified: December 28, 2012 by James M. Lynes, Jr.
//
// Modified for chipKIT UNO support(Doesn't support PINC syntax)
// Polls PORTD, not interrupt driven
// Encoder seems to have about 1 count jitter
//

#define ENC_A 5                        // PORTD RD1
#define ENC_B 6                        // PORTD RD2
 
void setup()
{
  /* Setup encoder pins as inputs */
  pinMode(ENC_A, INPUT);
  digitalWrite(ENC_A, HIGH);		// Enable internal pullups

  pinMode(ENC_B, INPUT);
  digitalWrite(ENC_B, HIGH);		// Enable internal pullups

  Serial.begin (115200);
  Serial.println("Start Rotary Encoder Driver");
}
 
void loop()
{
	static uint8_t counter = 0;    	  //this variable will be changed by encoder input
	int8_t tmpdata;
 
	tmpdata = read_encoder();	 // -1(CCW), 0(STOP), 1(CW)
	if( tmpdata != 0 )
	{
		Serial.print("Ctr: ");
		Serial.println(counter, HEX);
		counter += tmpdata;
	}
}
 
// Returns change in encoder state (-1,0,1)
int8_t read_encoder()
{
	static int8_t enc_states[] = {0,-1,1,0,1,0,0,-1,-1,0,0,1,0,1,-1,0};
	static uint8_t AB = 0;
	static uint8_t old_AB = 3;
	static int8_t encval = 0;   		// encoder value
	AB =  (PORTD >> 1) & 0x03; 		// Read/mask PORTD bits 
	old_AB = old_AB <<2;   	// remember previous state
	old_AB |= AB;			  	// add current state
	encval = enc_states[( old_AB & 0x0f )];
	if(encval && (AB ==3)) {
	return encval;
	}
	else return 0;
}
