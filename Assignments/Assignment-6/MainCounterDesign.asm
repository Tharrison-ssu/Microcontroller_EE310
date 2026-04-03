; Title: 7-Segment Counter
; Author: Taine Harrison
; Versions:
; V1: Working code
;-----------------------------------------------------------
; Device: PIC18F47K42
; Compiler: MPLAB X IDE - pic-as Assembler
; Includes: ConfigFile.inc, xc.inc
;-------------------------------------------------------------
; Purpose:
; This program controls a 7-segment display using a PIC18F47K42.
; Two push-button switches are used to control counting behavior.
; A)Press and hold Switch A, count UP (0 -> F)
; B) Press and hold Switch B, count DOWN (F -> 0)
; C) Press both switches, reset display to 0
; D) No switch pressed, hold last displayed value
; The display cycles through hexadecimal values (0?F).
;------------------------------------------------------------
; Inputs:
; RB0: Switch A (active HIGH)
; RB1: Switch B (active HIGH)
;---------------------------------------------------------------
; Outputs:
; RD0-RD6: 7-Segment display segments (a-g) (Common Cathode)
;------------------------------------------------------------
; Program Features:
; Uses CALL instruction to implement delay between counts
; Uses indirect addressing for 7-segment lookup
;================================================================
;------------------------------------------------------------
; Wiring Connections
;
; RB0  -> Button A (active HIGH)
; RB1  -> Button B (active HIGH)
;
; RD0  -> 7-seg segment a (with 220 resistor)
; RD1  -> 7-seg segment b (with 220 resistor)
; RD2  -> 7-seg segment c (with 220 resistor)
; RD3  -> 7-seg segment d (with 220 resistor)
; RD4  -> 7-seg segment e (with 220 resistor)
; RD5  -> 7-seg segment f (with 220 resistor)
; RD6  -> 7-seg segment g (with 220 resistor)
;
; Note:
; - Use a common cathode 7-segment display
; - All segment lines require current-limiting resistors
;------------------------------------------------------------

        #include "ConfigFile.inc"
        #include <xc.inc>

IdleState       equ     0x00
UpState         equ     0x01
DownState       equ     0x02
ResetState      equ     0x03

ValueReg        equ     0x20
ModeReg         equ     0x21
DelayOuterReg   equ     0x22
DelayInnerReg   equ     0x23

PSECT absdata,abs,ovrld

        ORG     0x0000
        GOTO    EntryPoint

        ORG     0x0020

EntryPoint:
        CALL    InitPorts
        CALL    RefreshDisplay

LoopForever:
        CALL    ReadButtons

        MOVF    ModeReg,0,0
        XORLW   ResetState
        BTFSC   STATUS,2
        CALL    DoResetState

        MOVF    ModeReg,0,0
        XORLW   UpState
        BTFSC   STATUS,2
        CALL    StepUp

        MOVF    ModeReg,0,0
        XORLW   DownState
        BTFSC   STATUS,2
        CALL    StepDown

        MOVF    ModeReg,0,0
        XORLW   IdleState
        BTFSC   STATUS,2
        CALL    HoldDisplay

        GOTO    LoopForever

InitPorts:
        BANKSEL ANSELB
        CLRF    ANSELB,1
        CLRF    ANSELD,1

        BANKSEL TRISB
        MOVLW   0x03
        MOVWF   TRISB,1

        BANKSEL TRISD
        MOVLW   0x80
        MOVWF   TRISD,1

        BANKSEL LATD
        CLRF    LATD,1

        CLRF    ValueReg,0
        CLRF    ModeReg,0
        CLRF    DelayOuterReg,0
        CLRF    DelayInnerReg,0
        RETURN

ReadButtons:
        CLRF    ModeReg,0
        BANKSEL PORTB

        BTFSC   PORTB,0
        GOTO    ButtonA

        BTFSC   PORTB,1
        GOTO    ButtonB

        RETURN

ButtonA:
        BTFSC   PORTB,1
        GOTO    BothButtons

        MOVLW   UpState
        MOVWF   ModeReg,0
        RETURN

ButtonB:
        MOVLW   DownState
        MOVWF   ModeReg,0
        RETURN

BothButtons:
        MOVLW   ResetState
        MOVWF   ModeReg,0
        RETURN

DoResetState:
        CLRF    ValueReg,0
        CALL    RefreshDisplay
        RETURN

HoldDisplay:
        CALL    RefreshDisplay
        RETURN

StepUp:
        CALL    WaitBlock
        CALL    WaitBlock
        CALL    WaitBlock

        INCF    ValueReg,1,0

        MOVF    ValueReg,0,0
        XORLW   0x10
        BTFSC   STATUS,2
        CLRF    ValueReg,0

        CALL    RefreshDisplay
        RETURN

StepDown:
        CALL    WaitBlock
        CALL    WaitBlock
        CALL    WaitBlock

        MOVF    ValueReg,0,0
        XORLW   0x00
        BTFSC   STATUS,2
        GOTO    LoadHexF

        DECF    ValueReg,1,0
        CALL    RefreshDisplay
        RETURN

LoadHexF:
        MOVLW   0x0F
        MOVWF   ValueReg,0
        CALL    RefreshDisplay
        RETURN

RefreshDisplay:
        MOVF    ValueReg,0,0
        CALL    SegTable
        BANKSEL LATD
        MOVWF   LATD,1
        RETURN

SegTable:
        ADDWF   PCL,1
        RETLW   0x3F    ; 0
        RETLW   0x06    ; 1
        RETLW   0x5B    ; 2
        RETLW   0x4F    ; 3
        RETLW   0x66    ; 4
        RETLW   0x6D    ; 5
        RETLW   0x7D    ; 6
        RETLW   0x07    ; 7
        RETLW   0x7F    ; 8
        RETLW   0x6F    ; 9
        RETLW   0x77    ; A
        RETLW   0x7C    ; b
        RETLW   0x39    ; C
        RETLW   0x5E    ; d
        RETLW   0x79    ; E
        RETLW   0x71    ; F

WaitBlock:
        MOVLW   0xFF
        MOVWF   DelayOuterReg,0

DelayOuter:
        MOVLW   0xFF
        MOVWF   DelayInnerReg,0

DelayInner:
        DECFSZ  DelayInnerReg,1,0
        GOTO    DelayInner

        DECFSZ  DelayOuterReg,1,0
        GOTO    DelayOuter
        RETURN

        END
