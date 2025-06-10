/*******************************************************************************************************
*   main.s
*   Organización y arquitectura de computadoras - UCC - 2025
*   Intregantes: Barg Emiliano y Gomez Nicolas Santiago.
*  
*   Este programa en Assembler sirve para una Raspberry PI 3B,
*   este programa usa el GPIO18 para hacer audio de 1 bit, usando una tabla con:
*
*       - Un valor que controla la duracion de medio periodo (controla la frecuencia).
*       - Un valor que controla la duracion de la nota (cuanto tiempo dura).
*
*   Tambien se implentan descansos, este programa reproduce el tema de la introduccion de Gravity Falls.
********************************************************************************************************/
.text

.equ PERIPHERAL_BASE, 0x3F000000    // Peripheral Base Address
.equ GPIO_BASE,         0x200000     // GPIO Base Address
.equ GPIO_GPFSEL1,      0x4          // GPIO Function Select 1 offset
.equ GPIO_GPSET0,       0x1C         // GPIO Pin Output Set 0 offset
.equ GPIO_GPCLR0,       0x28         // GPIO Pin Output Clear 0 offset

.global _start
_start:
    // ---------- Core Init  ----------
    // Set Cores 1..3 To Infinite Loop (no modificar)
    mrs x0, MPIDR_EL1           // X0 = Multiprocessor Affinity Register (MPIDR)
    ands x0, x0, #3             // X0 = CPU ID (Bits 0..1)
    b.ne CoreLoop               // IF (CPU ID != 0) Branch To Infinite Loop (Core ID 1..3)

    // ---------- Setup del GPIO  ----------
    // Computamos el puntero a GPIO:
    ldr x0, =PERIPHERAL_BASE
    add x0, x0, #GPIO_BASE      // x0 ahora apunta a los registros de  GPIO
    // Guardamos en X9 el puntero base a GPIO.
    mov x9, x0

    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop 8

    // Configuramos GPIO18 como output.
    // En GPIO_GPFSEL1, los bits 24-26 controlan GPIO18. Ponemos en 001 para que sea output.
    ldr w1, [x0, #GPIO_GPFSEL1]
    bic w1, w1, #(7 << 24)      // Llevamos a 0 los bits 24-26 para GPIO18
    orr w1, w1, #(1 << 24)      // Seteamos en el bit 24 (001: output)
    str w1, [x0, #GPIO_GPFSEL1]

    // ---------- SETUP PARA LA CANCION -----------------
    // Guardamos la dir donde esta la tabla con las notas.
    ldr x20, =melody
    // Guardamos la cantidad total de notas 117 en la tabla.
    mov x21, #117              
    // Iniciamos el contador en 0.
    mov x22, #0
    add xzr,xzr,xzr //nop 16

melody_loop:
    cmp x22, x21
    b.ge end_melody          // If index >= notas total, terminamos

    // Cada entrada de la tabla es 16 bytes (2 x .quad values).
    // Computamos la dir de la siguiente nota: x20 + (x22 << 4)
    mov x12, x22
    lsl x12, x12, #4         // x12 = x22 * 16
    add x12, x20, x12        // x12 ahora apunta a la direccion de la nota actual

    // Cargamos el limite  para la frecuencia en x10.
    ldr x10, [x12, #0]
    // Cargamos el limite para la dur en x11 (offset 8 bytes).
    ldr x11, [x12, #8]

    // ---------- IF Rest ----------
    cmp x10, #1 // 24
    beq rest_loop            // If half‑period = 1, vamos a un descanso (pause)



toggle_loop:
    // ---------- Generacion del pulso para la nota  ----------
    // GPIO18 a high.
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop 32
    mov w1, #1
    lsl w1, w1, #18         // Mascara para GPIO18 (bit 18)
    str w1, [x9, #GPIO_GPSET0]

    // Delay para medio periodo.
    mov x0, x10
    bl delay

    // GPIO18 a low.
    mov w1, #1
    lsl w1, w1, #18 
    str w1, [x9, #GPIO_GPCLR0] // 40


    // Delay de vuelta para medio periodo.
    mov x0, x10
    bl delay

    // Disminuimos el indice para la duracion.
    subs x11, x11, #1
    b.gt toggle_loop        // If toggle count > 0, repetimos.

    b next_note             // Terminamos, vamos para la siguiente nota 36

rest_loop:
    // ---------- Delay (Descanso) ----------
    mov x0, x11             // Ahora la duracion es la duracion del rest.
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop 48
delay_rest:
    bl delay
    subs x0, x0, #1
    b.gt delay_rest

next_note:
    add x22, x22, #1        // Aumentamos el index y volvemos al loop.
    b melody_loop

end_melody:
    // Cuando termina la cancion: nos quedamos en un loop infinito.
    b end_melody
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop 56

// ---------- Delay (Nota) ----------
// Input: x0 = delay counter
// Revisamos el contador y hay un nop para asegurar
// que la duracion de cada ciclo sea constante.
delay:
    cbz x0, delay_done      // If counter == 0, salimos del delay.
delay_loop:
    nop                     // Nop para que el tiempo sea mas constante.
    subs x0, x0, #1         // Disminuimos el contador.
    b.ne delay_loop         // Repetir hasta llegar a 0
delay_done:
    ret                     // Return.

// ---------- Infinite Loop for Cores 1-3 ----------
CoreLoop:
    b CoreLoop //49

// ---------- Tabla de Notas (Datos) ----------
// Hay que asegurarse que los valores .quad esten bien alineados..

    // Inicio de tabla
.align 3
    melody:
        .quad 4320, 131    // F5, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 6800, 83    // A4, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 4320, 131    // F5, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 6800, 83    // A4, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 4320, 131    // F5, seminegra
        .quad 5740, 98    // C5, seminegra
        .quad 6800, 83    // A4, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 4320, 131    // F5, seminegra
        .quad 5740, 98    // C5, seminegra
        .quad 6800, 83    // A4, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 4550, 124    // E5, seminegra
        .quad 5450, 104    // C#5, seminegra
        .quad 6800, 83    // A4, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 4550, 124    // E5, seminegra
        .quad 5740, 98    // C5, seminegra
        .quad 6800, 83    // A4, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 4550, 124    // E5, seminegra
        .quad 5450, 104    // C#5, seminegra
        .quad 6800, 83    // A4, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 4550, 124    // E5, seminegra
        .quad 5740, 98    // C5, seminegra
        .quad 6800, 83    // A4, seminegra
        .quad 5140, 110    // D5, seminegra
        .quad 5140, 551    // D5, blanca con punto
        .quad 4550, 247    // E5, negra
        .quad 4320, 1048    // F5, blanca completa
        .quad 3428, 495    // A5, negra con punto
        .quad 3830, 147    // G5, seminegra
        .quad 1, 10000    // rest, seminegra
        .quad 3830, 294    // G5, negra
        .quad 3428, 330    // A5, negra
        .quad 5740, 785    // C5, blanca completa
        .quad 5140, 551    // D5, blanca con punto
        .quad 4550, 247    // E5, negra
        .quad 4320, 524    // F5, blanca
        .quad 4550, 494    // E5, blanca
        .quad 3830, 588    // G5, blanca
        .quad 3428, 660    // A5, blanca
        .quad 3830, 588    // G5, blanca
        .quad 4320, 524    // F5, blanca
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 3428, 330    // A5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3428, 330    // A5, negra
        .quad 3830, 294    // G5, negra
        .quad 4320, 262    // F5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 3428, 330    // A5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3428, 330    // A5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3428, 330    // A5, negra
        .quad 3830, 294    // G5, negra
        .quad 3428, 330    // A5, negra
        .quad 3830, 294    // G5, negra
        .quad 4320, 262    // F5, negra
        .quad 4320, 262    // F5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 3428, 330    // A5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3428, 330    // A5, negra
        .quad 3830, 294    // G5, negra
        .quad 4320, 262    // F5, negra
        .quad 4320, 262    // F5, negra
        .quad 3428, 330    // A5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3428, 330    // A5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3428, 330    // A5, negra
        .quad 3428, 330    // A5, negra
        .quad 2730, 416    // C#6, negra
        .quad 1, 10000    // rest, seminegra
        .quad 2900, 392    // C6, negra
        .quad 1, 10000    // rest, seminegra
        .quad 2900, 392    // C6, negra
        .quad 2900, 392    // C6, negra
        .quad 4320, 262    // F5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 4320, 262    // F5, negra
        .quad 3428, 330    // A5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3428, 330    // A5, negra
        .quad 3830, 294    // G5, negra
        .quad 4320, 262    // F5, negra
        .quad 4320, 262    // F5, negra
        .quad 3050, 370    // B5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3050, 370    // B5, negra
        .quad 1, 10000    // rest, seminegra
        .quad 3050, 370    // B5, negra
        .quad 3830, 588    // G5, blanca
        .quad 2900, 785    // C6, blanca
        .quad 3428, 660    // A5, blanca
        .quad 2730, 832    // C#6, blanca
        .quad 2590, 1762    // D6, blanca completa
