//******************************************************************************
//Universidad del Valle de GUatemala
//IE023: Programación de Microcontroladores
//Autor: Astryd Rolinda Magaly Beb Caal
//Proyecto: PRELAB 2, TIMER0 como contador de 4bits a 100ms
//Hardware: ATMEGA328P
//Created: 1-01-2024

//*****************************************************************************
//Encabezado
//*****************************************************************************
.include "M328PDEF.inc"
.org 0x0000 ; Dirección de inicio del programa
rjmp  RESET
//*****************************************************************************
//tabla de valores
//*****************************************************************************

segDis: .DB  0x06, 0xB3, 0x97, 0xC6, 0xD5, 0xF5, 0x07, 0xF7, 0xD7, 0xE7, 0xF4, 0x71, 0xB6, 0xF1, 0xE1, 0x77
//*****************************************************************************
; stack pointer
//*****************************************************************************

LDI R16, LOW(RAMEND)
OUT SPL, R16 
LDI R17, HIGH(RAMEND)
OUT SPH, R17

//*****************************************************************************

//Configuraciones
//*****************************************************************************

RESET:
    ; Configuración del prescaler a 1MHz
    LDI R16, (1 << CLKPCE) ; Habilitar cambio de prescaler
    STS CLKPR, R16          ; Habilitando el prescaler
    LDI R16, 0b0000_0100    ; Prescaler a 1MHz
    STS CLKPR, R16          ; Establecer prescaler a 1MHz

    ; Configura el puerto C como salidas
    LDI R18, (1 << PC0) | (1 << PC1) | (1 << PC2) | (1 << PC3)
    OUT DDRC, R18 ; Configurar PC3, PC2, PC1 y PC0 como salidas

    ; Configura Timer0 con prescaler de 1024 y valor inicial de TCNT0 aproximado a 155
    LDI R16, (1 << CS02) | (1 << CS00) ; Configura el prescaler en 1024
    OUT TCCR0B, R16
    LDI R16, 155       ; Carga el valor aproximado de TCNT0 para 100 ms
    OUT TCNT0, R16

	 ; Configura el puerto D como salidas
    ldi R19, 0xFF ; Configurar todos los pines de PORTD como salidas
    out DDRD, R19

    ; Configura el puerto B como entrada con pull-up en PB0 y PB1
    ldi R19, (1 << PB0) | (1 << PB1) ; Configurar PB0 y PB1 como entrada
    out DDRB, R19 ; Configurar PB0 y PB1 como entrada
    out PORTB, R19
    
    ldi ZL, low(segDis<<1)
    ldi ZH, high(segDis<<1)

//*****************************************************************************
// Bucle Principal
//*****************************************************************************
Main:
    ; Llamada a la función de Timer0
    rcall timer0
    ; Llamada a la función de display
    rcall display
    ; Volver al bucle principal
    rjmp Main

//*****************************************************************************
//timer 0
//*****************************************************************************

timer0:
    ; Espera activamente hasta que la bandera de desbordamiento del Timer0 se establezca
WAIT_FOR_OVERFLOW:
    SBIS TIFR0, TOV0 ; Verifica si la bandera de desbordamiento del Timer0 está establecida
    RJMP WAIT_FOR_OVERFLOW ; Espera activamente si la bandera no está establecida

    ; Reinicia la bandera de desbordamiento del Timer0
    SBI TIFR0, TOV0

    ; Incrementa el contador binario de 4 bits en el puerto C
    IN R16, PORTC     ; Leer el estado actual del puerto C
    INC R16           ; Incrementar el contador
    CPI R16, 16       ; Comprobar si ha alcanzado el límite de 16
    BRNE UPDATE_PORTC ; Si R16 no es igual a 16, actualizar PORTC
    CLR R16           ; Reiniciar a 0 si es igual a 16

UPDATE_PORTC:
    OUT PORTC, R16 ; Actualizar el puerto C con el nuevo valor de R16
    ret

//*****************************************************************************
//display
//*****************************************************************************

display:
    ; Leer el estado del botón de incremento (PB0)
    sbic PINB, 0
    rjmp check_pb1 ; Saltar a la comprobación del botón PB1 si PB0 no está presionado

    ; Espera para el antirrebote
    ldi R22, 250

delay_loop1:
    dec R22
    brne delay_loop1

    ; Incrementar el índice del display
    inc R25
    cpi R25, 16   ; Comprobar si se ha alcanzado el final del display
    brne show_digit

    ; Si se alcanza el final del display, reiniciar el índice
    ldi R25, 1  ; Configurar el índice a la posición inicial
    rjmp display ; Volver al loop principal

check_pb1:
    ; Leer el estado del botón de decremento (PB1)
    sbic PINB, 1
    rjmp display ; Si PB1 no está presionado, volver al loop principal

    ; Espera para el antirrebote
    ldi R22, 250
delay_loop2:
    dec R22
    brne delay_loop2

    ; Decrementar el índice del display
    dec R25
    cpi R25, 1   ; Comprobar si se ha alcanzado el inicio del display
    brne show_digit ; Mostrar el dígito correspondiente si no se ha alcanzado el inicio

    ; Si se alcanza el inicio del display, configurar el índice al máximo
    ldi R25, 16 ; Índice máximo
    rjmp show_digit ; Mostrar el último dígito del display

show_digit:
    ; Mostrar el dígito correspondiente en el display
    add ZL, R25    ; Apuntar al byte correspondiente en la matriz de segmentos
    lpm R19, Z     ; Cargar el valor del dígito desde la memoria de programa
    out PORTD, R19    ; Mostrar en el display

    ; Espera un tiempo para el antirrebote
    ldi R22, 255      ; Retardo para el antirrebote
DELAY:
    dec R22
    brne DELAY


    ret
