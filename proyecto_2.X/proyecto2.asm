; PIC16F887 Configuration Bit Settings

#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 

;				VARIABLES
;****************************************************************************
GPR_VAR	    UDATA
VALOR_ADC   RES 1
NIBBLE_H    RES 1
NIBBLE_L    RES 1
BANDERAS    RES 1
W_TEMP	    RES 1
VAR_STATUS  RES 1
TIEMPO_1    RES 1
TIEMPO_2    RES 1
ENVIAR	    RES 1
	    
	    
;				INTERRUPCIONES
;*******************************************************************************
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

ISR_VECT    CODE    0x0004

PUSH:
    BCF	    INTCON, GIE
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   VAR_STATUS

ISR:
    BTFSC   INTCON, T0IF
    CALL    FUE_TMR0
    BTFSC   PIR1, RCIF
    BSF	    PORTC, RC3
    
POP:
    SWAPF   VAR_STATUS, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

;		    SUB-RUTINAS DE LA INTERRUPCION 
;*******************************************************************************

FUE_TMR0:
    MOVLW   .248
    MOVWF   TMR0
    CALL    DISPLAYS
    BCF	    INTCON, T0IF 

    RETURN
    
    
;				TABLA
;******************************************************************************* 

TABLA
;   87654321
;   .BAFGCDE
    ANDLW   B'00001111'		; 0-F
    ADDWF   PCL
    
    RETLW   B'10001000'		; 0	ABCDEF
    RETLW   B'10111011'		; 1	BC
    RETLW   B'10010100'		; 2	ABGED
    RETLW   B'10010001'		; 3	ABCDG
    RETLW   B'10100011'		; 4	BCFG
    RETLW   B'11000001'		; 5	ACDFG
    RETLW   B'11000000'		; 6	ACDEFG
    RETLW   B'10011011'		; 7	ABC
    RETLW   B'10000000'		; 8	ABCDEFG
    RETLW   B'10000001'		; 9	ABCDFG
    RETLW   B'10000010'		; A	ABCEFG
    RETLW   B'11100000'		; b	CDEFG
    RETLW   B'11001100'		; C	ADEF
    RETLW   B'10110000'		; d	BCDEG
    RETLW   B'11000100'		; E	ADEFG
    RETLW   B'11000110'		; F	AEFG
    RETURN
    
;			    PRINCIPAL 
;****************************************************************************
MAIN_PROG   CODE

START
   CALL	    CONFIG_IO
   CALL	    CONFIG_TMR0		    ; 2 mS
   CALL	    CONFIG_INTERRUPT
   CALL	    CONFIG_OSC
   CALL	    CONFIG_ADC
   CALL	    CONFIG_SERIAL
   GOTO	    LOOP
   
LOOP
    BTFSC   PORTB, RB0
    BCF	    PORTE, RE2
    BTFSS   PORTB, RB0
    BSF	    PORTE, RE2
   CALL	    DELAY_1
   BSF	    ADCON0, GO	    ;CONVERSION
   BTFSC    ADCON0, GO
   GOTO	    $-1
   BCF	    PIR1, ADIF	    ;BANDERA TERMINAR CONVERSION
   MOVFW    ADRESH
   MOVWF    ENVIAR	    ;VALOR DE ADRESH A VARIABLE ENVIAR
   
   ;ENVIAR LOS VALORES AL PUERTO D Y A LOS DISPLAYS
   BTFSS    PIR1, RCIF	    
   GOTO	    RECIBIDO  
   MOVFW    RCREG
   MOVWF    VALOR_ADC
   MOVFW    RCREG
   MOVWF    PORTD
   CALL	    CONTADOR
   GOTO	    LOOP
   
RECIBIDO
   BTFSS    PIR1, TXIF
   GOTO	    LOOP
   MOVFW    ENVIAR
   MOVWF    TXREG
   GOTO	    LOOP ;;;
   
CONTADOR
    ;SEPARAR NIBBLES
    CLRF    NIBBLE_L
    CLRF    NIBBLE_H
    MOVFW   VALOR_ADC
    ANDLW   B'00001111'
    MOVWF   NIBBLE_L
    SWAPF   VALOR_ADC, W
    ANDLW   B'00001111'
    MOVWF   NIBBLE_H
    GOTO    LOOP
   
DISPLAYS:
    BTFSC   BANDERAS, 0
    GOTO    DISPLAY1
    BTFSC   BANDERAS, 1
    GOTO    DISPLAY2
DISPLAY1
    CLRF    PORTE
    MOVFW   NIBBLE_H
    CALL    TABLA
    MOVWF   PORTB
    BSF	    PORTE, RE0
    CLRF    BANDERAS
    BSF	    BANDERAS, 1
    RETURN

DISPLAY2
    CLRF    PORTE
    MOVFW   NIBBLE_L
    CALL    TABLA
    MOVWF   PORTB
    BSF	    PORTE, RE1
    CLRF    BANDERAS
    BSF	    BANDERAS, 0
    RETURN
    


;				CONFIGURACIONES
;*******************************************************************************
   
CONFIG_IO
   BANKSEL  ANSEL
   CLRF	    ANSEL
   COMF	    ANSEL
   BANKSEL  TRISA
   CLRF	    TRISA
   COMF	    TRISA
   CLRF	    TRISB
   CLRF	    TRISD
   CLRF	    TRISE
   BANKSEL  PORTD
   CLRF	    PORTA
   CLRF	    PORTB
   CLRF	    PORTE
   CLRF	    PORTD
   RETURN
   
CONFIG_OSC 
   BANKSEL  OSCCON
   MOVLW    B'01100001'
   MOVFW    OSCCON
   RETURN
   
CONFIG_ADC
   BANKSEL  ADCON1
   CLRF	    ADCON1
   BANKSEL  ADCON0
   MOVLW    B'01000001'
   MOVWF    ADCON0
   RETURN
   

CONFIG_TMR0			    ; 2 mS PARA DISPLAYS
    BANKSEL OPTION_REG
    CLRWDT
    MOVLW   b'01010111'
    MOVWF   OPTION_REG
    RETURN

    
CONFIG_INTERRUPT
    ; CUANDO SE PRENDE LA BANDERA HABRA UNA INTERRUPCION TIMER0 
    ;BSF	    INTCON, GIE
    ; INTERRUPCION TIMER 1 Y 2
    BANKSEL TRISA
    BSF	    PIE1, TMR1IE
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    
    BANKSEL PORTA
    BSF	    INTCON, GIE
    BCF	    INTCON, T0IF
    RETURN
    
CONFIG_SERIAL
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC
    BSF	    TXSTA, BRGH
    BANKSEL BAUDCTL
    BSF	    BAUDCTL, BRG16
    BANKSEL SPBRG
    MOVLW   .25
    MOVWF   SPBRG
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN
    BCF	    RCSTA, RX9
    BSF	    RCSTA, CREN
    BANKSEL TXSTA
    BSF	    TXSTA, TXEN
    BANKSEL PORTA
    RETURN
   
DELAY_1
    MOVLW   .250
    MOVWF   TIEMPO_1
CONFIG1:
    CALL    DELAY_2
    DECFSZ  TIEMPO_1, F
    GOTO    CONFIG1
RETURN

DELAY_2
    MOVLW   .250
    MOVWF    TIEMPO_2
CONFIG2:
    DECFSZ  TIEMPO_2, F
    GOTO    CONFIG2
RETURN
   
END