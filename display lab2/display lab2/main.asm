//******************************************************************************
//Universidad del Valle de GUatemala
//IE023: Programaci�n de Microcontroladores
//Autor: Astryd Rolinda Magaly Beb Caal
//Proyecto:Display de 7 segmentos
//Hardware: ATMEGA328P
//Created: 6-02-2024

//*****************************************************************************
.include "M328PDEF.inc"

.org 0x0000
    rjmp inicio
//**********************************************************
//Tabla de valores
//**********************************************************
segDis: .DB  0x06, 0xB3, 0x97, 0xC6, 0xD5, 0xF5, 0x07, 0xF7, 0xD7, 0xE7, 0xF4, 0x71, 0xB6, 0xF1, 0xE1, 0x77
//**********************************************************
inicio:
    ; Configuraci�n del prescaler a 1MHz
    ldi R16, (1 << CLKPCE) ; Habilitar prescaler
    sts CLKPR, R16          ; Habilitando el prescaler
    ldi R16, 0b0000_0100    ; Prescaler a 1MHz
    sts CLKPR, R16          ; Establecer prescaler a 1MHz

    ; Configura el puerto D como salidas
    ldi R19, 0xFF ; Configurar todos los pines de PORTD como salidas
    out DDRD, R19

    ; Configura el puerto B como entrada con pull-up en PB0 y PB1
    ldi R19, (1 << PB0) | (1 << PB1) ; Configurar PB0 y PB1 como entrada
    out DDRB, R19 ; Configurar PB0 y PB1 como entrada
    out PORTB, R19
    
  //**********************************************************
  Bucle principal
 //**********************************************************  

loop:
	ldi R25, 0
	ldi ZL, low(segDis<<1)
    ldi ZH, high(segDis<<1)
    ; Leer el estado del bot�n de incremento (PB0)
    sbic PINB, 0
    rjmp check_pb1 ; Saltar a la comprobaci�n del bot�n PB1 si PB0 no est� presionado

; Espera para el antirrebote
    ldi R22, 250
delay_loop1:
    dec R22
    brne delay_loop1
	sbic PINB, 0
  ; Incrementar el �ndice del display
    inc R25
    cpi R25, 16   ; Comprobar si se ha alcanzado el final del display
    brne mostrar

    ; Si se alcanza el final del display, reiniciar el �ndice
    ldi R25, 1  ; Configurar el �ndice a la posici�n inicial
    rjmp loop ; Volver al loop principal

//***********************************************************************************************
;Revisar el bot�n de decremento
//***********************************************************************************************
check_pb1:
    ; Leer el estado del bot�n de decremento (PB1)
    sbic PINB, 1
    rjmp loop ; Si PB1 no est� presionado, volver al loop principal

    ; Espera para el antirrebote
    ldi R22, 250
delay_loop2:
    dec R22
    brne delay_loop2

    ; Decrementar el �ndice del display
    dec R25
    cpi R25, 1   ; Comprobar si se ha alcanzado el inicio del display
    brne mostrar ; Mostrar el d�gito correspondiente si no se ha alcanzado el inicio

    ; Si se alcanza el inicio del display, configurar el �ndice al m�ximo
    ldi R25, 16 ; �ndice m�ximo
    rjmp mostrar ; Mostrar el �ltimo d�gito del display

//***********************************************************************************************
;mostrar en display
//***********************************************************************************************
mostrar:
    ldi ZL, low(segDis<<1)
    ldi ZH, high(segDis<<1); Mostrar el d�gito correspondiente en el display
    add ZL, R25    ; Apuntar al byte correspondiente en la matriz de segmentos
    lpm R19, Z     ; Cargar el valor del d�gito desde la memoria de programa
    out PORTD, R19    ; Mostrar en el display

    ; antirrebote
    ldi R22, 255      ; Retardo para el antirrebote
DELAY:
    dec R22
    brne DELAY

    ; Volver al loop principal
    rjmp loop