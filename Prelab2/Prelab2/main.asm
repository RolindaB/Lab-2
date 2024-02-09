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

//***************************
//Configuraciones
//***************************
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

//***************************
// Bucle Principal
//***************************
MAIN_LOOP:
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
    RJMP MAIN_LOOP ; Volver al bucle principal