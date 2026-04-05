#include <xc.h>
#include "HeaderC.h"   // include your header file

#define _XTAL_FREQ 4000000
#define FCY (_XTAL_FREQ/4)

void main(void)
{
    TRISD = 0b00000000;   // Set PORTD as output
    PORTD = 0b00000000;   // Initialize PORTD to LOW

    while(1)
    {
        PORTDbits.RD1 = 0;   // LED ON (would 0 not be off?)
        __delay_ms(500);

        PORTDbits.RD1 = 1;   // LED OFF
        __delay_ms(500);
    }
}
