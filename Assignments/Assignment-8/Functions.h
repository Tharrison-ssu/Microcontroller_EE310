#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include "Initialization.h"

// --------------------------------------------------
// Function prototypes
// --------------------------------------------------
void OSCILLATOR_Initialize(void);
void GPIO_Initialize(void);
void INTERRUPT_Initialize(void);
void SYSTEM_Initialize(void);

void display_blank(void);
void display_digit(uint8_t digit);

uint8_t pr1_is_active(void);
uint8_t pr2_is_active(void);

void relay_on(void);
void relay_off(void);
void short_beep(void);
void correct_code_action(void);
void wrong_code_action(void);
void reset_outputs_for_next_entry(void);

uint8_t capture_digit_from_pr1(void);
uint8_t capture_digit_from_pr2(void);

// --------------------------------------------------
// 7-segment helpers
// --------------------------------------------------
static void set_segments(uint8_t a, uint8_t b, uint8_t c,
                         uint8_t d, uint8_t e, uint8_t f, uint8_t g)
{
#if (COMMON_CATHODE == 1u)
    SEG_A_LAT = a;
    SEG_B_LAT = b;
    SEG_C_LAT = c;
    SEG_D_LAT = d;
    SEG_E_LAT = e;
    SEG_F_LAT = f;
    SEG_G_LAT = g;
#else
    SEG_A_LAT = !a;
    SEG_B_LAT = !b;
    SEG_C_LAT = !c;
    SEG_D_LAT = !d;
    SEG_E_LAT = !e;
    SEG_F_LAT = !f;
    SEG_G_LAT = !g;
#endif
}

void display_blank(void)
{
    set_segments(0, 0, 0, 0, 0, 0, 0);
}

void display_digit(uint8_t digit)
{
    switch (digit)
    {
        case 0: set_segments(1,1,1,1,1,1,0); break;
        case 1: set_segments(0,1,1,0,0,0,0); break;
        case 2: set_segments(1,1,0,1,1,0,1); break;
        case 3: set_segments(1,1,1,1,0,0,1); break;
        case 4: set_segments(0,1,1,0,0,1,1); break;
        default: display_blank(); break;
    }
}

// --------------------------------------------------
// Input helpers
// --------------------------------------------------
uint8_t pr1_is_active(void)
{
#if (PR1_ACTIVE_LEVEL == 1u)
    return (PR1_PORT == 1u);
#else
    return (PR1_PORT == 0u);
#endif
}

uint8_t pr2_is_active(void)
{
#if (PR2_ACTIVE_LEVEL == 1u)
    return (PR2_PORT == 1u);
#else
    return (PR2_PORT == 0u);
#endif
}

// --------------------------------------------------
// Relay helpers
// --------------------------------------------------
void relay_on(void)
{
    RELAY_LAT = 1;
}

void relay_off(void)
{
    RELAY_LAT = 0;
}

void short_beep(void)
{
    relay_on();
    __delay_ms(70);
    relay_off();
}

void correct_code_action(void)
{
    relay_on();
    __delay_ms(3000);
    relay_off();
}

void wrong_code_action(void)
{
    relay_on();
    __delay_ms(2000);
    relay_off();
}

void reset_outputs_for_next_entry(void)
{
    relay_off();
    display_blank();
}

// --------------------------------------------------
// Digit capture
// One count = one full cover/uncover cycle
// --------------------------------------------------
uint8_t capture_digit_from_pr1(void)
{
    uint8_t count = 0u;
    uint8_t busy = 0u;
    uint16_t idle_ms = 0u;

    display_digit(0u);

    while (1)
    {
        if (g_emergency_latched)
        {
            return 0u;
        }

        if (pr1_is_active())
        {
            busy = 1u;
            idle_ms = 0u;
        }
        else
        {
            if (busy)
            {
                if (count < MAX_DIGIT_VALUE)
                {
                    count++;
                    display_digit(count);
                    short_beep();
                }

                busy = 0u;
                idle_ms = 0u;
            }
            else
            {
                __delay_ms(10);

                if (count > 0u)
                {
                    idle_ms += 10u;

                    if (idle_ms >= DIGIT_DONE_TIMEOUT_MS)
                    {
                        return count;
                    }
                }
            }
        }
    }
}

uint8_t capture_digit_from_pr2(void)
{
    uint8_t count = 0u;
    uint8_t busy = 0u;
    uint16_t idle_ms = 0u;

    display_digit(0u);

    while (1)
    {
        if (g_emergency_latched)
        {
            return 0u;
        }

        if (pr2_is_active())
        {
            busy = 1u;
            idle_ms = 0u;
        }
        else
        {
            if (busy)
            {
                if (count < MAX_DIGIT_VALUE)
                {
                    count++;
                    display_digit(count);
                    short_beep();
                }

                busy = 0u;
                idle_ms = 0u;
            }
            else
            {
                __delay_ms(10);

                if (count > 0u)
                {
                    idle_ms += 10u;

                    if (idle_ms >= DIGIT_DONE_TIMEOUT_MS)
                    {
                        return count;
                    }
                }
            }
        }
    }
}

// --------------------------------------------------
// Initialization
// --------------------------------------------------
void OSCILLATOR_Initialize(void)
{
    // Clock source selected by configuration bits
}

void GPIO_Initialize(void)
{
    ANSELA = 0x00;
    ANSELB = 0x00;
    ANSELD = 0x00;

    // Inputs
    TRISAbits.TRISA1 = 1;   // PR1
    TRISAbits.TRISA2 = 1;   // PR2
    TRISBbits.TRISB0 = 1;   // Emergency switch

    // Outputs
    TRISAbits.TRISA0 = 0;   // System LED
    TRISBbits.TRISB1 = 0;   // Relay

    TRISDbits.TRISD0 = 0;   // 7-seg A
    TRISDbits.TRISD1 = 0;   // 7-seg B
    TRISDbits.TRISD2 = 0;   // 7-seg C
    TRISDbits.TRISD3 = 0;   // 7-seg D
    TRISDbits.TRISD4 = 0;   // 7-seg E
    TRISDbits.TRISD5 = 0;   // 7-seg F
    TRISDbits.TRISD6 = 0;   // 7-seg G

    SYS_LED_LAT = 0;
    RELAY_LAT = 0;
    display_blank();
}

void INTERRUPT_Initialize(void)
{
    // Clear INT0 flag
    PIR1bits.INT0IF = 0;

    // Enable INT0 source
    PIE1bits.INT0IE = 1;

    // Falling edge for active-low emergency switch
    INTCON0bits.INT0EDG = 0;

    // Enable high-priority interrupts and global interrupts
    INTCON0bits.IPEN = 1;
    INTCON0bits.GIEH = 1;
    INTCON0bits.GIEL = 1;
}

void SYSTEM_Initialize(void)
{
    OSCILLATOR_Initialize();
    GPIO_Initialize();
    INTERRUPT_Initialize();

    SYS_LED_LAT = 1;
    RELAY_LAT = 0;
    display_blank();
}

// --------------------------------------------------
// INT0 Vectored ISR for PIC18F47K42 with MVECEN = ON
// Microchip XC8 vector-table style uses irq(INT0), base(8).
// --------------------------------------------------
void __interrupt(irq(INT0), base(8)) INT0_ISR(void)
{
    uint8_t i;

    PIR1bits.INT0IF = 0;

    g_emergency_latched = 1u;
    relay_off();

    for (i = 0; i < 3; i++)
    {
        relay_on();
        __delay_ms(120);
        relay_off();
        __delay_ms(80);
    }

    __delay_ms(180);

    for (i = 0; i < 2; i++)
    {
        relay_on();
        __delay_ms(300);
        relay_off();
        __delay_ms(120);
    }

    __delay_ms(180);

    for (i = 0; i < 4; i++)
    {
        relay_on();
        __delay_ms(70);
        relay_off();
        __delay_ms(70);
    }

    relay_off();
}

#endif