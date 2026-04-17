/*
 * Title: Sensor Interface Control
 * Author: Taine Harrison
 *
 * Revision History:
 * V1.0 : 4/11/2026 - Initial 
 *
 * ------------------------------------------------------------
 * Device:   PIC18F47K42
 * Compiler: MPLAB X IDE + XC8 v3.10
 * Includes: ConfigFile.h, Initialization.h, Functions.h
 * ------------------------------------------------------------
 *
 * Purpose:
 * This program manages a safebox sensor interface using a
 * PIC18F47K42 microcontroller.
 *
 * System Overview:
 * - Two photoresistors for touchless input (PR1, PR2)
 * - Emergency pushbutton interrupt
 * - 7-segment display for feedback
 * - System LED for status indication
 * - Relay module controlling motor/buzzer
 *
 * Operation Summary:
 * - System initializes hardware
 * - Waits for PR1 input, then PR2 input
 * - Compares input to secret code
 * - Executes correct or incorrect action
 * - Interrupt triggers emergency behavior
 *
 * Inputs:
 * RA1 : PR1
 * RA2 : PR2
 * RB0 : Emergency switch
 *
 * Outputs:
 * RA0      : System LED
 * RB1      : Relay control
 * RD0-RD6  : 7-segment display
 */

#include <xc.h>
#include "ConfigFile.h"
#include "Initialization.h"
#include "Functions.h"

int main(void)
{
    uint8_t first_digit;
    uint8_t second_digit;

    SYSTEM_Initialize();
    reset_outputs_for_next_entry();

    while (1)
    {
        if (g_emergency_latched)
        {
            while (1)
            {
                SYS_LED_LAT = 1;
            }
        }

        first_digit = capture_digit_from_pr1();

        if (g_emergency_latched)
        {
            continue;
        }

        display_digit(first_digit);
        __delay_ms(700);

        second_digit = capture_digit_from_pr2();

        if (g_emergency_latched)
        {
            continue;
        }

        display_digit(second_digit);
        __delay_ms(700);

        if ((first_digit == SECRET_DIGIT_1) &&
            (second_digit == SECRET_DIGIT_2))
        {
            correct_code_action();
        }
        else
        {
            wrong_code_action();
        }

        __delay_ms(500);
        reset_outputs_for_next_entry();
    }
}
