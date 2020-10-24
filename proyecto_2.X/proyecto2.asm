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
RECIBIDO   RES 1
NIBBLE_H    RES 1
NIBBLE_L    RES 1
BANDERAS    RES 1
W_TEMP	    RES 1
VAR_STATUS  RES 1
TIEMPO_1    RES 1
TIEMPO_2    RES 1
ENVIAR	    RES 1
DISPLAY_1   RES 1
DISPLAY_2   RES 1
DISPLAY_3   RES 1
DISPLAY_4   RES 1
   
   
	    
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
    BTFSC   PIR1, TMR2IF
    CALL    FUE_TMR2
    BTFSC   PIR1, ADIF
    CALL    COSO_ADC
    BTFSC   PIR1, RCIF
    CALL    COSO_RX
    
POP:
    SWAPF   VAR_STATUS, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

;		    SUB-RUTINAS DE LA INTERRUPCION 
;*******************************************************************************

FUE_TMR2:
    BTFSC   PIR1, TXIF
    CALL    COSO_TX
    BCF	    PIR1, TMR2IF
    RETURN
   
FUE_TMR0:
    MOVLW   .248
    MOVWF   TMR0
    CALL    DISPLAYS
    BCF	    INTCON, T0IF 
    RETURN

COSO_ADC:
   BCF	    PIR1, ADIF	    ;BANDERA TERMINAR CONVERSION
   MOVFW    ADRESH
   MOVWF    ENVIAR	    ;VALOR DE ADRESH A VARIABLE ENVIAR
   BSF	    ADCON0, 1
   RETURN
   
COSO_TX:
    MOVFW   ENVIAR
    MOVWF   TXREG
    RETURN
    
COSO_RX:
    MOVFW   RCREG
    MOVWF   PORTD
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
   CALL	    CONFIG_TMR		    ; 2 mS
   CALL	    CONFIG_INTERRUPT
   CALL	    CONFIG_OSC
   CALL	    CONFIG_ADC
   CALL	    CONFIG_SERIAL
   GOTO	    LOOP
   
LOOP:
    CLRF    DISPLAY_1
    CLRF    DISPLAY_2
    MOVFW   PORTD
    ANDLW   B'00001111'
    MOVWF   DISPLAY_1
    SWAPF   PORTD, W
    ANDLW   B'00001111'
    MOVWF   DISPLAY_2
    GOTO    LOOP
   
;*******************************************************************************
DISPLAYS:
    BTFSC   BANDERAS, 0
    GOTO    DISPLAY1
    BTFSC   BANDERAS, 1
    GOTO    DISPLAY2
DISPLAY1
    CLRF    PORTE
    MOVFW   DISPLAY_1
    CALL    TABLA
    MOVWF   PORTB
    BSF	    PORTE, RE0
    CLRF    BANDERAS
    BSF	    BANDERAS, 1
    RETURN

DISPLAY2
    CLRF    PORTE
    MOVFW   DISPLAY_2
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
   BSF	    ANSEL, 0
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
   
CONFIG_ADC:
   BANKSEL  ADCON1
   CLRF	    ADCON1
   BANKSEL  ADCON0
   MOVLW    B'10000011'
   MOVWF    ADCON0
   RETURN
   

CONFIG_TMR			    ; 2 mS PARA DISPLAYS
    BANKSEL OPTION_REG
    CLRWDT
    MOVLW   b'01010111'
    MOVWF   OPTION_REG			    ; 1 SEGUNDO PARA LEDS
    BANKSEL PORTA
    MOVLW   .255
    MOVWF   T2CON
    RETURN

    
CONFIG_INTERRUPT:
    BANKSEL TRISA
    BSF	    PIE1, ADIE
    BSF	    PIE1, TMR1IE
    BSF	    PIE1, TMR2IE
    BSF	    PIE1, RCIE
    BSF	    PIE1, TXIE
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    
    MOVLW   .20
    MOVWF   PR2
    
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

END