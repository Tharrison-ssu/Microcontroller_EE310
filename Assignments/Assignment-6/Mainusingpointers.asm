; Author: Taine Harrison
; Device: PIC18F47K42
; Compiler: MPLAB X IDE - pic-as Assembler
; Includes: ConfigFile.inc, xc.inc
;-------------------------------------------------------------
; Purpose:
;This code is the same as the main code but was swapped out for cleaner code after I finished the assignment 
;where the use of pointers were needed
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

Tbl0            equ     0x30
Tbl1            equ     0x31
Tbl2            equ     0x32
Tbl3            equ     0x33
Tbl4            equ     0x34
Tbl5            equ     0x35
Tbl6            equ     0x36
Tbl7            equ     0x37
Tbl8            equ     0x38
Tbl9            equ     0x39
TblA            equ     0x3A
TblB            equ     0x3B
TblC            equ     0x3C
TblD            equ     0x3D
TblE            equ     0x3E
TblF            equ     0x3F

PSECT absdata,abs,ovrld

        ORG     0x0000
        GOTO    EntryPoint

        ORG     0x0020

EntryPoint:
        CALL    InitPorts
        CALL    LoadTable
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
        MOVLW   0x30
        MOVWF   FSR0L,0
        CLRF    FSR0H,0

        MOVF    ValueReg,0,0
        ADDWF   FSR0L,1,0

        MOVF    INDF0,0,0
        BANKSEL LATD
        MOVWF   LATD,1
        RETURN

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

LoadTable:
        MOVLW   0x3F
        MOVWF   Tbl0,0
        MOVLW   0x06
        MOVWF   Tbl1,0
        MOVLW   0x5B
        MOVWF   Tbl2,0
        MOVLW   0x4F
        MOVWF   Tbl3,0
        MOVLW   0x66
        MOVWF   Tbl4,0
        MOVLW   0x6D
        MOVWF   Tbl5,0
        MOVLW   0x7D
        MOVWF   Tbl6,0
        MOVLW   0x07
        MOVWF   Tbl7,0
        MOVLW   0x7F
        MOVWF   Tbl8,0
        MOVLW   0x6F
        MOVWF   Tbl9,0
        MOVLW   0x77
        MOVWF   TblA,0
        MOVLW   0x7C
        MOVWF   TblB,0
        MOVLW   0x39
        MOVWF   TblC,0
        MOVLW   0x5E
        MOVWF   TblD,0
        MOVLW   0x79
        MOVWF   TblE,0
        MOVLW   0x71
        MOVWF   TblF,0
        RETURN

        END
