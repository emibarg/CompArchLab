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
    mov x21, #12
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
    // Al terminar la melodia volvemos a empezar.
    mov x22, #0
    b melody_loop

// Procedure de delay:
// Input: X0 = delay counter
delay:
    subs x0, x0, #1
    b.ne delay
    ret

// Infinite Loop for Cores 1-3
CoreLoop:
    b CoreLoop

// Tabla con notas
// Esta directiva hace que se alinee en 8 bytes lo que queremos guardar.
.align 3
melody:
    // Octava 4
    //.quad 11500, 1309    // DO 261.8  vs 261.63
    //.quad 10230, 1469     // RE  294.3 vs 293.66
    //.quad 9100, 1649    // MI  330.9 vs 329.63
    //.quad 8650, 1747     // FA   348.1vs 349.23
    //.quad 7700, 1960     // SOL   391 vs 392
    //.quad 6800, 2200     // LA  442 vs 440
    //.quad 6100, 2470     // SI 493.5 vs 493.88
	//Octava 5
	.quad 5740, 1589 // DO 524.5 vs 523.25
	.quad 5450, 1664 // DO# 552.3 vs 554.36
	.quad 5140, 1762 // RE 585.7 vs 587.33
	.quad 4850, 1887 // RE# 620.7 vs 622.25
	.quad 4550, 1978 // MI 661.5 vs 659.25
	.quad 4320, 2095 // FA 696.7 vs 698.46
	.quad 4075, 2220 // FA# 738.6 vs 739.99
	.quad 3830, 2351 // SOL 785.7 vs 783.99
	.quad 3633, 2492 // SOL# 828.3 vs 830.61
	.quad 3428, 2640 // LA 878 vs 880
	.quad 3225, 2797 // LA# 933 vs 932.33
	.quad 3050, 2963 // SI 986 vs 987.76
	


