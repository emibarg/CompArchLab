/*********************************************************************************************
*	main.s
*	Organización y arquitectura de computadoras - UCC
*   2025
**********************************************************************************************/
.text

.equ PERIPHERAL_BASE, 0x3F000000 // Peripheral Base Address
.equ GPIO_BASE, 0x200000 	// GPIO Base Address
.equ GPIO_GPFSEL1, 0x4 		// GPIO Function Select 1
.equ GPIO_GPSET0, 0x1C 		// GPIO Pin Output Set 0
.equ GPIO_GPCLR0, 0x28 		// GPIO Pin Output Clear 0

.global _start
_start:
	// Set Cores 1..3 To Infinite Loop
	mrs X0, MPIDR_EL1 	// X0 = Multiprocessor Affinity Register (MPIDR)
	ands X0, X0, 3 		// X0 = CPU ID (Bits 0..1)
	b.ne CoreLoop 		// IF (CPU ID != 0) Branch To Infinite Loop (Core ID 1..3)

	// Load GPIO base address into X0
	ldr X0, = (PERIPHERAL_BASE + GPIO_BASE)

	// Configure GPIO18 as output (FSEL1)
	mov w1, #1
	lsl w1, w1, #24      // Set bits 24-26 for GPIO18 (001)
	str w1, [x0, #GPIO_GPFSEL1]


	// Set the delay to 0x186A00
	movz w3, #(1136000 & 0xFFFF), lsl #0
	movk w3, #(1136000 >> 16), lsl #16

infloop:
	// Set GPIO18 (turn on)
	mov w1, #1
	lsl w1, w1, #18
	str w1, [x0, #GPIO_GPSET0]

	// Delay loop
	mov w2, w3
a:	subs w2, w2, #100
	b.ne a

	// Clear GPIO18 (turn off)
	mov w1, #1
	lsl w1, w1, #18
	str w1, [x0, #GPIO_GPCLR0]

	// Delay loop
	mov w2, w3
bb:	subs w2, w2, #100
	b.ne bb

	b infloop

CoreLoop: // Infinite Loop For Core 1..3
	b CoreLoop
    