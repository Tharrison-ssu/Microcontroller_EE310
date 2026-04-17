#ifndef INITIALIZATION_H
#define INITIALIZATION_H

#include <xc.h>
#include <stdint.h>

// Only define _XTAL_FREQ here if ConfigFile.h did not already define it
#ifndef _XTAL_FREQ
#define _XTAL_FREQ 4000000UL
#endif

// -----------------------------
// Secret code

// -----------------------------
#define SECRET_DIGIT_1          2u
#define SECRET_DIGIT_2          2u

// Assignment says inputs are small counts.
// Allow 0..4 safely.
#define MAX_DIGIT_VALUE         4u

// Timeout used to determine digit entry completion
#define DIGIT_DONE_TIMEOUT_MS   1500u

// Set to 1 if covering photoresistor makes input HIGH
// Set to 0 if covering photoresistor makes input LOW
#define PR1_ACTIVE_LEVEL        0u
#define PR2_ACTIVE_LEVEL        0u

// 7-segment type
// 1 = common cathode (segment ON = logic 1)
// 0 = common anode   (segment ON = logic 0)
#define COMMON_CATHODE          1u


#define SYS_LED_LAT             LATAbits.LATA0
#define PR1_PORT                PORTAbits.RA1
#define PR2_PORT                PORTAbits.RA2

#define EMERG_SW_PORT           PORTBbits.RB0
#define RELAY_LAT               LATBbits.LATB1

#define SEG_A_LAT               LATDbits.LATD0
#define SEG_B_LAT               LATDbits.LATD1
#define SEG_C_LAT               LATDbits.LATD2
#define SEG_D_LAT               LATDbits.LATD3
#define SEG_E_LAT               LATDbits.LATD4
#define SEG_F_LAT               LATDbits.LATD5
#define SEG_G_LAT               LATDbits.LATD6


volatile uint8_t g_emergency_latched = 0u;

// init functions
void SYSTEM_Initialize(void);
void OSCILLATOR_Initialize(void);
void GPIO_Initialize(void);
void INTERRUPT_Initialize(void);

#endif