;============================================================
; Title:      Signed Temperature Compare and Decimal Display
; 
; Author:     Taine Harrison
; Date:       March 11, 2026
;
; Program:    FirstAssemblyProgramMain.asm
; Device:     PIC18F46K42
; Compiler:   MPLAB X IDE with XC8 (pic-as assembler)
;
; Purpose:
;   This program compares two signed 8-bit temperature values:
;   - refTemp (reference temperature)
;   - measuredTemp (measured temperature)
;
;   It determines whether the measured temperature is:
;       Equal to reference
;       Below reference
;       Above reference
;
;   The result is stored in contReg and indicated using the bits of LATD:
;       RD1 = Below reference
;       RD2 = Above reference
;       Both clear = Equal
;
;   Both temperature values are converted to their absolute
;   decimal representation (tens and ones digits) and stored in:
;       Reference: 0x60–0x62
;       Measured:  0x70–0x72
;
; Inputs:
;   refTemp        (0x20) – Signed 8-bit reference temperature
;   measuredTemp   (0x21) – Signed 8-bit measured temperature
;
; Outputs:
;   contReg        (0x22) – Comparison result
;   LATD<1:2>      – Status indicators
;   REF_ONES/TENS/HUNDS   – Reference decimal digits
;   MEAS_ONES/TENS/HUNDS  – Measured decimal digits
;
; Dependencies:
;   xc.inc
;   MyConfigFile.inc
;
; Revision History:
;   v1.0 – Working code
;   v1.1 - Added header
;   v1.2 - Added comments for each section
;============================================================
	PROCESSOR   18F46K42
        #include    <xc.inc>
        #include    "MyConfigFile.inc"

refTemp             EQU     0x20
measuredTemp        EQU     0x21
contReg             EQU     0x22

tempValue           EQU     0x23
tensPlaceTemp       EQU     0x24

REF_ONES            EQU     0x60
REF_TENS            EQU     0x61
REF_HUNDS           EQU     0x62

MEAS_ONES           EQU     0x70
MEAS_TENS           EQU     0x71
MEAS_HUNDS          EQU     0x72


;============================================================
; RESET VECTOR (your working method)
;============================================================
        PSECT   absdata,abs,ovrld        ; Do not change
        ORG     0x0000

__reset:
        GOTO    ProgramStart



; MAIN PROGRAM 

        ORG     0x0020

ProgramStart:

        MOVLW   15
        MOVWF   refTemp, a  ;Sets reference temperature in register 0x20

        MOVLW   0xFB
        MOVWF   measuredTemp, a  ;Sets measured temperature in register 0x20

        CLRF    LATD, a
        CLRF    TRISD, a   ;Sets latd and portd to outputs


        MOVF    refTemp, W, a
        SUBWF   measuredTemp, W, a

        BTFSC   STATUS, 2, a
        GOTO    TemperaturesEqual

        BTFSS   STATUS, 4, a
        GOTO    NegativeFlagClear

;-----------------------------
; Case: N == 1 (result sign negative)
; If OV==0, negative is "real" -> measured < ref
; If OV==1, sign is flipped by overflow -> measured > ref
;-----------------------------

NegativeFlagSet:
        BTFSS   STATUS, 3, a
        GOTO    MeasuredBelowReference
        GOTO    MeasuredAboveReference

;-----------------------------
; Case: N == 0 (result sign positive)
; If OV==0, positive is "real" -> measured > ref
; If OV==1, sign is flipped by overflow -> measured < ref
;-----------------------------

NegativeFlagClear:
        BTFSC   STATUS, 3, a
        GOTO    MeasuredBelowReference
        GOTO    MeasuredAboveReference

;============================================================
; Takes comparision results and stores in latd
;============================================================

TemperaturesEqual:
        CLRF    contReg, a
        BCF     LATD, 1, a
        BCF     LATD, 2, a
        GOTO    ConvertTemperaturesToDigits

MeasuredBelowReference:
        MOVLW   0x01
        MOVWF   contReg, a
        BSF     LATD, 1, a
        BCF     LATD, 2, a
        GOTO    ConvertTemperaturesToDigits

MeasuredAboveReference:
        MOVLW   0x02
        MOVWF   contReg, a
        BCF     LATD, 1, a
        BSF     LATD, 2, a

;============================================================
; Decimal Conversion
; Converts each signed temperature to absolute value
; and splits into tens and ones.
; After ConvertToAbsoluteDecimal:
; tempValue = ones digit (0-9)
; tensPlaceTemp = tens digit
;============================================================

ConvertTemperaturesToDigits:

        MOVF    refTemp, W, a
        MOVWF   tempValue, a
        CALL    ConvertToAbsoluteDecimal

        MOVF    tempValue, W, a
        MOVWF   REF_ONES, b

        MOVF    tensPlaceTemp, W, a
        MOVWF   REF_TENS, b

        CLRF    REF_HUNDS, b

        MOVF    measuredTemp, W, a
        MOVWF   tempValue, a
        CALL    ConvertToAbsoluteDecimal

        MOVF    tempValue, W, a
        MOVWF   MEAS_ONES, b

        MOVF    tensPlaceTemp, W, a
        MOVWF   MEAS_TENS, b

        CLRF    MEAS_HUNDS, b

;============================================================
; Infinite loop so program doesn't run into empty memory
;============================================================

ForeverLoop:
        GOTO    ForeverLoop

;============================================================
; Functions below
;============================================================

ConvertToAbsoluteDecimal:

        BTFSS   tempValue, 7, a
        GOTO    AbsoluteReady
        COMF    tempValue, F, a
        INCF    tempValue, F, a

AbsoluteReady:
        CLRF    tensPlaceTemp, a

FindTensLoop:
        MOVLW   10
        SUBWF   tempValue, F, a

        BTFSS   STATUS, 0, a
        GOTO    TensCalculationComplete

        INCF    tensPlaceTemp, F, a
        GOTO    FindTensLoop

TensCalculationComplete:
        BTFSC   STATUS, 0, a
        RETURN
        MOVLW   10
        ADDWF   tempValue, F, a
        RETURN

        END
