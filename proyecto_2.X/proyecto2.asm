; PIC16F887 Configuration Bit Settings

#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 

;				VARIABLES
;*******************************************************************************
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
RECIBIDO_Y1 RES 1
RECIBIDO_Y2 RES 1
ENVIAR_X    RES 1
RECIBIDO_X1 RES 1
RECIBIDO_X2 RES 1
X_1	    RES 1
X_2	    RES 1
Y_1	    RES 1
Y_2	    RES 1
X_1_ENVIAR  RES 1
X_2_ENVIAR  RES 1
Y_1_ENVIAR  RES 1
Y_2_ENVIAR  RES 1
DISPLAYX1   RES 1
DISPLAYX2   RES 1
DISPLAYY1   RES 1
DISPLAYY2   RES 1
   
   
	    
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
    CALL    FUE_TMR0	    ; BANDERA DEL TIMER0, DISPLAYS
    BTFSC   PIR1, TMR2IF
    CALL    FUE_TMR2	    ; TIMER2 PARA AUMENTAR EL TIEMPO PARA ENVIAR DATOS
    BTFSC   PIR1, ADIF
    CALL    COSO_ADC	    ; CONVERSION
    BTFSC   PIR1, RCIF
    CALL    COSO_RX	    ; RECIBIR DATOS
    
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
    CALL    DISPLAYS	    ;VARIANDO QUE DISPLAY ESTA PRENDIDO
    BCF	    INTCON, T0IF 
    RETURN

COSO_ADC:
   BTFSC    EJE, 0
   GOTO	    EJE_Y
   EJE_X	     ; VARIAR EN QUE VARIABLE SE GUARDA EL VALOR Y EL CANAL	    
   MOVFW    ADRESH	   
   MOVWF    ENVIAR_X	    ;VALOR DE ADRESH A VARIABLE ENVIAR
   BSF	    EJE, 0
   BSF	    ADCON0, 2
   CALL	    DELAY_2	; DARLE TIEMPO ANTES DE LA SIGUIENTE CONVERSION
   GOTO	    TERMINAR
   
   EJE_Y	    ; CONVERSION EN EL CANAL AN1
   MOVFW    ADRESH  ; GUARDAR VALOR EN LA VARIABLE PARA EL EJE Y
   MOVWF    ENVIAR_Y	  
   BCF	    EJE, 0
   BCF	    ADCON0, 2
   CALL	    DELAY_2
   
   TERMINAR
   BSF	    ADCON0, 1
   BCF	    PIR1, ADIF	    ;BANDERA TERMINAR CONVERSION
   RETURN
   
COSO_TX:
    ;MOVLW   0X14
    ;MOVWF   ENVIAR_Y
    ;MOVLW   0xBA
    ;MOVWF   ENVIAR_X
    BTFSC   EJE, 1	 ; PRIMERO ENVIAR EL VALOR EN X, LUEGO UNA COMA
    GOTO    ENVIAR_EJEY	 ; LUEGO EL VALOR EN Y Y LUEGO UN ENTER
    BTFSC   EJE, 3
    GOTO    ENVIAR_COMA
    
    ENVIAR_EJEX		  ; EJE, 1 EN CLEAR Y EJE, 3 EN CLEAR, ENVIAR X
    MOVFW   ENVIAR_X
    CALL    TABLA_ASCII
    MOVWF   X_2_ENVIAR
    SWAPF   ENVIAR_X, W
    MOVWF   X_2
    MOVFW   X_2
    CALL    TABLA_ASCII
    MOVWF   X_1_ENVIAR
    
    BTFSC   EJE, 4
    GOTO    ENVIAR_X2
    
    ENVIAR_X1
    MOVFW   X_1_ENVIAR
    MOVWF   TXREG
    BSF	    EJE, 4
    RETURN
    
    ENVIAR_X2
    MOVFW   X_2_ENVIAR
    MOVWF   TXREG
    BSF	    EJE, 3
    BCF	    EJE, 4
    RETURN
    
    ENVIAR_COMA		; EJE, 1 EN CLEAR Y EJE, 3 EN SET, ENVIAR COMA
    MOVLW   .44		; COMA EN ASCII
    MOVWF   TXREG
    BSF	    EJE, 1
    BCF	    EJE, 3
    RETURN
  
    
    ENVIAR_EJEY			; EJE, 1 EN SET Y EJE, 3 EN CLEAR, ENVIAR Y
    BTFSC   EJE, 3
    GOTO    ENVIAR_ENTER
    MOVFW   ENVIAR_Y
    CALL    TABLA_ASCII
    MOVWF   Y_2_ENVIAR
    SWAPF   ENVIAR_Y, W
    MOVWF   Y_2
    MOVFW   Y_2
    CALL    TABLA_ASCII
    MOVWF   Y_1_ENVIAR
    
    BTFSC   EJE, 4
    GOTO    ENVIAR_Y2
    ENVIAR_Y1
    MOVFW   Y_1_ENVIAR
    MOVWF   TXREG
    BSF	    EJE, 4
    RETURN
    
    ENVIAR_Y2
    MOVFW   Y_2_ENVIAR
    MOVWF   TXREG
    BSF	    EJE, 3
    BCF	    EJE, 4
    RETURN
    
    ENVIAR_ENTER	; EJE, 1 EN SET Y EJE, 3 EN SET, ENVIAR ENTER
    MOVLW   .10		; ENTER EN ASCII
    MOVWF   TXREG
    BCF	    EJE, 1
    BCF	    EJE, 3
    RETURN
    
COSO_RX:		    ; PRIMERA RECEPCION ES COORDENADA EN X 
    BTFSC   EJE, 2	    ; Y LA SEGUNDA ES COORDENADA EN Y
    GOTO    RECIBIDOS_Y
    
    RECIBIDO_X
    BTFSC   EJE, 5
    GOTO    RX2
    RX1
    MOVFW   RCREG
    MOVWF   RECIBIDO_X1
    BSF	    EJE, 5
    RETURN
    
    RX2
    BTFSC   EJE, 6
    GOTO    COMA
    MOVFW   RCREG
    MOVWF   RECIBIDO_X2
    BSF	    EJE, 6
    RETURN
    
    COMA
    MOVLW   .44
    SUBWF   RCREG
    BTFSS   STATUS, Z
    RETURN
    BCF	    EJE, 6
    BSF	    EJE, 2
    BCF	    EJE, 5
    RETURN
    
    RECIBIDOS_Y
    BTFSC   EJE, 5
    GOTO    RY2
    RY1
    MOVFW   RCREG
    MOVWF   RECIBIDO_Y1
    BSF	    EJE, 5
    RETURN
    
    RY2
    BTFSC   EJE, 6
    GOTO    ENTER
    MOVFW   RCREG
    MOVWF   RECIBIDO_Y2
    BSF	    EJE, 6
    RETURN
    
    ENTER
    MOVLW   .10
    SUBWF   RCREG, W
    BTFSS   STATUS, Z
    RETURN
    BCF	    EJE, 6
    BCF	    EJE, 5
    BCF	    EJE, 2
    RETURN
;				TABLA
;******************************************************************************* 

TABLA_ASCII
;   87654321
;   .BAFGCDE
    ANDLW   B'00001111'		; 0-F
    ADDWF   PCL
    
    RETLW   0x30		; 0	ABCDEF
    RETLW   0X31
    RETLW   0X32
    RETLW   0X33
    RETLW   0X34
    RETLW   0X35
    RETLW   0X36
    RETLW   0X37
    RETLW   0X38
    RETLW   0X39
    RETLW   0X41
    RETLW   0X42
    RETLW   0X43
    RETLW   0X44
    RETLW   0X45
    RETLW   0X46
    RETURN
    
    
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

START			    ; CONFIGURACIONES
   CALL	    CONFIG_IO
   CALL	    CONFIG_TMR
   CALL	    CONFIG_INTERRUPT
   CALL	    CONFIG_OSC
   CALL	    CONFIG_ADC
   CALL	    CONFIG_SERIAL
   GOTO	    LOOP
   
LOOP:
    
    MOVLW   0x30
    SUBWF   RECIBIDO_Y1, W
    MOVWF   DISPLAY_1
    MOVLW   0x30
    SUBWF   RECIBIDO_Y2, W
    MOVWF   DISPLAY_2
    MOVLW   0x30
    SUBWF   RECIBIDO_X1, W
    MOVWF   DISPLAY_3
    MOVLW   0x30
    SUBWF   RECIBIDO_X2, W
    MOVWF   DISPLAY_4
    
    BSF	    ADCON0, GO
    GOTO    LOOP
    
;*******************************************************************************
DISPLAYS:			; IR VARIANDO QUE DISPLAY ESTA PRENDIDO
    BTFSC   BANDERAS, 0
    GOTO    DISPLAY1
    BTFSC   BANDERAS, 1
    GOTO    DISPLAY2
DISPLAY1			;PRENDER DISPLAY DE UNIDADES DE "X" Y "Y"
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

DISPLAY2			;PRENDER DISPLAY DE DECENAS DE "X" Y "Y"
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
   BSF	    ANSEL, 0	; CONFIGURAR ANSEL PARA EL CANAL AN0 Y AN1
   BSF	    ANSEL, 1
   CLRF	    ANSELH
   BANKSEL  TRISA
   CLRF	    TRISA
   COMF	    TRISA	; PONER COMO INPUT EL PUERTO A
   CLRF	    TRISB
   CLRF	    TRISD
   CLRF	    TRISE	; COLOCAR PUERTOS COMO SALIDAS
   BANKSEL  PORTD
   CLRF	    PORTA
   CLRF	    PORTB
   CLRF	    PORTE
   CLRF	    PORTD
   CLRF	    ENVIAR_Y	 ; PONER EN 0 LAS VARIABLES A USAR
   CLRF	    ENVIAR_X
   CLRF	    DISPLAY_1
   CLRF	    DISPLAY_2
   CLRF	    DISPLAY_3
   CLRF	    DISPLAY_4
   CLRF	    ENVIAR_Y
   CLRF	    RECIBIDO_Y1
   CLRF	    RECIBIDO_Y2
   CLRF	    ENVIAR_X
   CLRF	    RECIBIDO_X1
   CLRF	    RECIBIDO_X2
   CLRF	    X_1
   CLRF	    X_2
   CLRF	    Y_1
   CLRF	    Y_2
   CLRF	    DISPLAYX1
   CLRF	    DISPLAYX2
   CLRF	    DISPLAYY1
   CLRF	    DISPLAYY2
   CLRF	    EJE
   RETURN
   
CONFIG_OSC		; CONFIGURACION DEL RELOJ
   BANKSEL  OSCCON
   MOVLW    B'01100001'
   MOVFW    OSCCON
   RETURN
   
CONFIG_ADC:		    ; CONFIGURACION ADC
   BANKSEL  ADCON1
   CLRF	    ADCON1
   BANKSEL  ADCON0
   MOVLW    B'10000111'	    ; CANAL INICIAL AN1
   MOVWF    ADCON0
   RETURN
   

CONFIG_TMR			    ; 2 mS PARA DISPLAYS
    BANKSEL OPTION_REG
    CLRWDT
    MOVLW   b'11010111'
    MOVWF   OPTION_REG	
    BANKSEL PORTA
    MOVLW   .255
    MOVWF   T2CON
    RETURN

    
CONFIG_INTERRUPT:
    BANKSEL TRISA
    BSF	    PIE1, ADIE		; HABILITAR INTERRUPCIONES DEL ADC, TX Y RX
    BSF	    PIE1, TMR1IE	; TMR0 Y TMR2
    BSF	    PIE1, TMR2IE
    BSF	    PIE1, RCIE
    ;BSF	    PIE1, TXIE
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    
    MOVLW   .20
    MOVWF   PR2
    
    BANKSEL PORTA
    BSF	    INTCON, GIE
    BCF	    INTCON, T0IF
    RETURN
  
CONFIG_SERIAL
    BANKSEL TXSTA	    ; CONFIGURACION DEL TX
    BCF	    TXSTA, SYNC
    BSF	    TXSTA, TXEN
    BSF	    TXSTA, BRGH
    BCF	    TXSTA, TX9
    
    BANKSEL BAUDCTL	    ; CONFIGURACION DE LA VELOCIDAD
    BCF	    BAUDCTL, BRG16
    BANKSEL SPBRG
    MOVLW   .25
    MOVWF   SPBRG
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN	    ; CONFIGURACION DEL RX
    BCF	    RCSTA, RX9
    BSF	    RCSTA, CREN
    BANKSEL PORTA
    RETURN


    
    DELAY_1		    ; DELAYS
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