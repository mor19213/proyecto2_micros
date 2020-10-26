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
NIBBLE_H    RES 1
NIBBLE_L    RES 1
BANDERAS    RES 1
W_TEMP	    RES 1
VAR_STATUS  RES 1
TIEMPO_1    RES 1
TIEMPO_2    RES 1
DISPLAY_1   RES 1
DISPLAY_2   RES 1
DISPLAY_3   RES 1
DISPLAY_4   RES 1
EJE	    RES 1
ENVIAR_Y    RES 1
RECIBIDO_Y  RES 1
ENVIAR_X    RES 1
RECIBIDO_X  RES 1
   
   
	    
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
    ;BSF	    PORTD, RD2
    RETURN
   
FUE_TMR0:
    MOVLW   .248
    MOVWF   TMR0
    CALL    DISPLAYS
    BCF	    INTCON, T0IF 
    ;BSF	    PORTD, RD3
    RETURN

COSO_ADC:
   BTFSC    EJE, 0
   GOTO	    EJE_Y
   EJE_X
   MOVFW    ADRESH
   MOVWF    ENVIAR_X	    ;VALOR DE ADRESH A VARIABLE ENVIAR
   BSF	    EJE, 0
   BSF	    ADCON0, 2
   ;MOVLW    B'10000111'
   ;MOVWF    ADCON0
   CALL	    DELAY_2
   GOTO	    TERMINAR
   
   EJE_Y 
   MOVFW    ADRESH
   MOVWF    ENVIAR_Y
   ;MOVFW    ENVIAR_Y
   ;ADDLW    0x30
   ;MOVWF    ENVIAR_Y
   BCF	    EJE, 0
   BCF	    ADCON0, 2
   ;MOVLW    B'10000011'
   ;MOVWF    ADCON0
   CALL	    DELAY_2
   
   TERMINAR
   ;BSF	    ADCON0, 1
   BCF	    PIR1, ADIF	    ;BANDERA TERMINAR CONVERSION
   RETURN
   
COSO_TX:
    ;MOVLW   0x45
    ;MOVWF   TXREG
    ;RETURN
    BTFSC   EJE, 1
    GOTO    ENVIAR_EJEY
    BTFSC   EJE, 3
    GOTO    ENVIAR_COMA
    ENVIAR_EJEX
    MOVFW   ENVIAR_X
    MOVWF   TXREG
    BSF	    EJE, 3
    RETURN
    
    ENVIAR_COMA
    MOVLW   .44
    MOVWF   TXREG
    BSF	    EJE, 1
    BCF	    EJE, 3
    RETURN
  
    
    ENVIAR_EJEY
    BTFSC   EJE, 3
    GOTO    ENVIAR_ENTER
    MOVFW   ENVIAR_Y
    MOVWF   TXREG
    BSF	    EJE, 3
    RETURN
    
    ENVIAR_ENTER
    MOVLW   .10
    MOVWF   TXREG
    BCF	    EJE, 1
    BCF	    EJE, 3
    RETURN
    
COSO_RX:
    BTFSC   EJE, 2
    GOTO    RECIBIDOS_Y
    
    RECIIDO_X
    MOVFW   RCREG
    MOVWF   RECIBIDO_X
    BSF	    EJE, 2
    RETURN
    
    RECIBIDOS_Y
    MOVFW   RCREG
    MOVWF   RECIBIDO_Y
    BCF	    EJE, 2
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
    ;MOVFW   RECIBIDO_Y
    ;MOVWF   PORTD
    CALL    DELAY_1
    BSF	    ADCON0, GO
    ;SEPARAR NIBBLES
    
    MOVFW   RECIBIDO_Y
    MOVWF   DISPLAY_4
    SWAPF   RECIBIDO_Y, W
    MOVWF   DISPLAY_3 
   
    MOVFW   RECIBIDO_X
    MOVWF   DISPLAY_2
    SWAPF   RECIBIDO_X, W
    MOVWF   DISPLAY_1
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
    MOVFW   DISPLAY_3
    CALL    TABLA
    MOVWF   PORTD
    BSF	    PORTE, RE0
    CLRF    BANDERAS
    BSF	    BANDERAS, 1
    RETURN

DISPLAY2
    CLRF    PORTE
    MOVFW   DISPLAY_2
    CALL    TABLA
    MOVWF   PORTB
    MOVFW   DISPLAY_4
    CALL    TABLA
    MOVWF   PORTD
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
   BSF	    ANSEL, 1
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
   CLRF	    ENVIAR_Y
   
   CLRF	    EJE
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
   MOVLW    B'10000111'
   MOVWF    ADCON0
   RETURN
   

CONFIG_TMR			    ; 2 mS PARA DISPLAYS
    BANKSEL OPTION_REG
    CLRWDT
    MOVLW   b'11010111'
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
    ;BSF	    PIE1, TXIE
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    
    MOVLW   .196
    MOVWF   PR2
    
    BANKSEL PORTA
    BSF	    INTCON, GIE
    BCF	    INTCON, T0IF
    RETURN
    
CONFIG_SERIAL
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC
    BSF	    TXSTA, TXEN
    BSF	    TXSTA, BRGH
    BCF	    TXSTA, TX9
    
    BANKSEL BAUDCTL
    BCF	    BAUDCTL, BRG16
    BANKSEL SPBRG
    MOVLW   .25
    MOVWF   SPBRG
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN
    BCF	    RCSTA, RX9
    BSF	    RCSTA, CREN
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