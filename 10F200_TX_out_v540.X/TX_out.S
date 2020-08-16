;
; File:     main.S
; Target:   PIC10F200
; Author:   dan1138
; Date:     2020-08-14
; Compiler: pic-as(v2.20)
; IDE:      MPLABX v5.40
;
; Depends on files:
;   <InstallPathVaries>\xc8\v2.20\pic\include\xc.inc
;   <InstallPathVaries>\xc8\v2.20\pic\include\pic.inc
;   <InstallPathVaries>\xc8\v2.20\pic\include\pic_as_chip_select.inc
;   <InstallPathVaries>\xc8\v2.20\pic\include\proc\pic10f206.inc
;
; Description:
;
;             PIC10F200
;         +-------_-------+
;         : 1 N/C   VPP 8 : <- GP3
;  VDD -> : 2 VDD   VSS 7 : <- VSS
;  GP2 <> : 3 T0CKI N/C 6 :       
;  GP1 <> : 4 PGC   PGD 5 : <> GP0
;         +---------------+
;               DIP-8
;
;   Example project for the PIC10F200 controller using the pic-as(v2.20) tool chain.
;
; Add this line in the project properties box "pic-as Global Options -> Additional options": 
;
;   -Wa,-a -Wl,-pStartCode=0h,-pOscCalVec=1ffh
;
    PROCESSOR   10F200
    PAGEWIDTH   250
    RADIX       dec
;
; Include target specific definitions for special function registers
;
#include <xc.inc>
;
; Set the configuration word
;
 config MCLRE = OFF, CP = OFF, WDTE = OFF
;
#define TX_out_bit_position (1)
;
; Declare one byte in RAM
;
    PSECT   MainData,global,class=RAM,space=1,delta=1,noexec
    global  TX_byte
TX_byte:      DS    1
StringOutIdx: DS    1

;
; PIC10F200 Serial TX output
;
; Baud rate is FOSC/(clocks per instruction cycle)/(instruction cycles per bit)
; or FOSC/4/8 with a 4MHz oscillator the baud rate is 125K bits per second.
;
; Warnings: 
;   The PIC10F200 4MHz oscillator accuracy is at best 1% so this will be unreliable.
;
;   This code uses Read-Modify-Write on a GPIO port register. This is known to have
;   problems when the GPIO output drives a low impedance load. You have been warned.
;

    PSECT   StartCode,class=CODE,delta=2
    movwf   OSCCAL
    goto    main
;
; Remember this is a baseline PIC so a called routinte
; entry must start in the first 256 instruction words.
;
TX_out:
    movwf   TX_byte                     ; Save byte to be sent
    bcf     GPIO,TX_out_bit_position    ; assert start bit
    rrf     TX_byte,W                   ; transform data bits
    xorwf   TX_byte,F                   ; to an NRZ pattern
    BSF     TX_byte,7
    movlw   (1<<TX_out_bit_position)    ; WREG = bit position mask of TX output bit
    NOP
TX_out_loop:
    btfsc   STATUS,STATUS_C_POSITION
    xorwf   GPIO,F                      ; assert bit 
    bcf     STATUS,STATUS_C_POSITION
    rrf     TX_byte,F                   ; shift out next bit to CARRY
    movf    TX_byte,F                   ; Test for ZERO, shows all bits have been sent.
    btfss   STATUS,STATUS_Z_POSITION
    goto    TX_out_loop
    GOTO    Tw
Tw: NOP
    bsf     GPIO,TX_out_bit_position    ; assert stop bit
    NOP
    NOP
    retlw   0
;
; Return character of ROM string
; Input:    WREG = Pointer to begining of string to be sent.
;           StringOutIdx = offsct from start of string.
;
; Output:   WREG = Character of string at StringOutIdx
;           StringOutIdx = StringOutIdx + 1
;
GetNextCharacter:
    addwf   StringOutIdx,W
    incf    StringOutIdx,F
    movwf   PCL
aszHello:   ; Strings to send must be located in the first 256 instruction words
; DT "Hello World!",0x0D,0x0A,0x00    ; MPASM syntax
  IRP char,'H','e','l','l','o',' ','W','o','r','l','d',33,13,10,0
    retlw char
  ENDM
;
; Main application
;
main:
    bcf     OSCCAL,OSCCAL_FOSC4_POSITION; Turn off CLOCK OUT on GPIO.GP2
    movlw   0b11000111                  ; TIMER0 clock is FOSC/4 with 1:256 prescaler
    option                              ;
    clrf    TMR0
;
; Wait about 500 milliseconds before setting the output bits after a POR.
; This prevents problems with the In-Circuit-Serial-Programming.
;
    movlw   16
    movwf   TX_byte
POR_WaitLoop:
    btfss   TMR0,7
    goto    POR_WaitLoop
    bcf     TMR0,7
    decfsz  TX_byte,F
    goto    POR_WaitLoop

    movlw   0xFF^(1<<TX_out_bit_position)
    tris    GPIO                        ; GP1 is the TX output bit
    bsf     GPIO,TX_out_bit_position    ; assert stop bit
;
; Wait for stop bit to be asserted for at least 10 bit times.
;
TX_InitWaitLoop:
    btfss   TMR0,7
    goto    TX_InitWaitLoop
;
; Send boot message
;
    clrf    StringOutIdx    ; Set String output index to first character
BootMessageLoop:
    movlw   aszHello        ; Pointer to string we are sending
    call    GetNextCharacter
    iorlw   0
    btfsc   STATUS,STATUS_Z_POSITION
    goto    Done
    call    TX_out
    goto    BootMessageLoop
Done:

hang:
    goto    hang
;
; In the PIC10F200 the factory calibration for
; the onchip oscillator is stored as a MOVLW 0xnn
; opcode as the last instruction of code space.
; On RESET the PC is set to all ones and this
; opcode is executed, then the PC rolls over
; to zero and the first opcode of the application
; will execute.
;
    PSECT   OscCalVec,class=CODE,delta=2
    global  OscCal
OscCal:

    end     OscCal