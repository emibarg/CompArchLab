/*********************************************************************************************
*   main.s
*   Organización y arquitectura de computadoras - UCC
*   2025
*
*   Tabla notas:
*     DO: 261 Hz    → medio‑periodo: 14300, counter_tiempo: 1566
*     RE: 293 Hz    → medio‑periodo: 12600, counter_tiempo: 1758
*     MI: 329 Hz    → medio‑periodo: 11200, counter_tiempo: 1974
*     FA: 349 Hz    → medio‑periodo:  10600,counter_tiempo: 2094
*     SOL:392 Hz    → medio‑periodo:  9400, counter_tiempo: 2352
*     LA: 440 Hz    → medio‑periodo:  8500, counter_tiempo: 2640
*     SI: 493 Hz    → medio‑periodo:  7600, counter_tiempo: 2958
**********************************************************************************************/
.text

.equ PERIPHERAL_BASE, 0x3F000000    // Peripheral Base Address
.equ GPIO_BASE, 0x200000            // GPIO Base Address offset
.equ GPIO_GPFSEL1, 0x4              // GPIO Function Select 1 offset
.equ GPIO_GPSET0, 0x1C              // GPIO Pin Output Set 0 offset
.equ GPIO_GPCLR0, 0x28              // GPIO Pin Output Clear 0 offset

.global _start

    // Set Cores 1..3 To Infinite Loop (no modificar)
    mrs x0, MPIDR_EL1          // X0 = Multiprocessor Affinity Register (MPIDR)
    ands x0, x0, #3            // X0 = CPU ID (Bits 0..1)
    b.ne CoreLoop              // IF (CPU ID != 0) Branch To Infinite Loop (Core ID 1..3)

    // Load in W0 the GPIO base address
    ldr x0, =PERIPHERAL_BASE
    add x0, x0, #GPIO_BASE     // X0 = 0x3F200000
    // X9 = X0 por comodidad
    mov x9, x0

    // Configure GPIO18 as an output. (usar GPIO_GPFSEL1)
    // En GPIO_GPFSEL1, bits 24-26 controlan GPIO18. Tenemos que setearlos a 001.
    ldr w1, [x0, #GPIO_GPFSEL1]
    bic w1, w1, #(7 << 24)     // Limpiar bits 24-26
    orr w1, w1, #(1 << 24)     // Setear bit 24 (001: output)
    str w1, [x0, #GPIO_GPFSEL1]

    // Setup para la tabla:
    // Cargamos el puntero a la dir de memoria de la tabla.
    ldr x20, =melody
    // Guardamos la cantidad de notas que hay.
    mov x21, #7
    // Iniciamos el indice.
    mov x22, #0

melody_loop:
    cmp x22, x21
    b.ge end_melody         // IF (index >= number of notes) terminamos

    // Cada nota tiene 16 bits de longitud (2 x .quad):
    // Calculamos la dir de la nota: x20 + (x22 << 4)
    mov x12, x22
    lsl x12, x12, #4         // x12 = x22 * 16
    add x12, x20, x12        // x12 ahora apunta a la nota actual

    // Cargamos el medio-periodo (primer quad) en X10.
    ldr x10, [x12, #0]
    // Cargamos el contador para el tiempo (segundo quad) en X11. (Offset 8 bytes)
    ldr x11, [x12, #8]

toggle_loop:
    // Generamos el pulso
    // GPIO18 = Alto.
    mov w1, #1
    lsl w1, w1, #18         // Mascara para GPIO18 (bit 18)
    str w1, [x9, #GPIO_GPSET0]

    // Llamamos al proceso de delay con la mitad del periodo.
    mov x0, x10
    bl delay

    // GPIO18 = Bajo.
    mov w1, #1
    lsl w1, w1, #18         // Mascara para GPIO18
    str w1, [x9, #GPIO_GPCLR0]

    // Delay de vuelta para el otro periodo.
    mov x0, x10
    bl delay

    // Disminuimos el counter para el tiempo.
    subs x11, x11, #1
    b.gt toggle_loop        // IF (toggle count > 0) repetimos

    // Siguiente nota:
    add x22, x22, #1        // Aumentamos el indice de nota.
    b melody_loop

end_melody:
    // Al terminar la melodia nos quedamos en un loop infinito.
    b end_melody

// Procedure de delay:
// Input: X0 = delay counter
delay:
    subs x0, x0, #1
    b.ne delay
    ret

// Infinite Loop for Cores 1-3
CoreLoop:
    b CoreLoop

// ---------- Melody Table (Data Section) ----------
// Ensure proper alignment for .quad values.
.align 3
melody:
    .quad 14300, 1566     // DO 261 Hz: half‑period delay, toggle count (~3 sec)
    .quad 12600, 1758     // RE 293 Hz
    .quad 11200, 1974     // MI 329 Hz
    .quad 10600, 2094     // FA 349 Hz
    .quad  9400, 2352     // SOL 392 Hz
    .quad  8500, 2640     // LA 440 Hz
    .quad  7600, 2958     // SI 493 Hz
