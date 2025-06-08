/*********************************************************************************************
*   main.s
*   Organización y arquitectura de computadoras - UCC
*   2025
*
*   This bare‑metal ARMv8 program for the Raspberry Pi 3 configures GPIO18 as an output,
*   then plays a melody with a note sequence. Each note uses:
*
*       - A half‑period delay value (controls the frequency/pitch).
*       - A toggle count (controls how many on/off pulses are produced).
*
*   Rests are implemented when the half‑period value is 0, using the toggle count as a delay multiplier.
**********************************************************************************************/
.text

.equ PERIPHERAL_BASE, 0x3F000000    // Peripheral Base Address
.equ GPIO_BASE,         0x200000     // GPIO Base Address
.equ GPIO_GPFSEL1,      0x4          // GPIO Function Select 1 offset
.equ GPIO_GPSET0,       0x1C         // GPIO Pin Output Set 0 offset
.equ GPIO_GPCLR0,       0x28         // GPIO Pin Output Clear 0 offset

.global _start
_start:
    // ---------- Core Initialization ----------
    // Get core ID. Only core 0 continues; cores 1-3 go into an infinite loop.
    mrs x0, MPIDR_EL1           // Read Multiprocessor Affinity Register
    ands x0, x0, #3             // Extract core ID bits (0..1)
    b.ne CoreLoop               // If core ID != 0, branch to infinite loop

    // ---------- GPIO Setup ----------
    // Compute the GPIO base pointer:
    ldr x0, =PERIPHERAL_BASE
    add x0, x0, #GPIO_BASE      // x0 now points to the GPIO registers
    // Save the GPIO base pointer in x9 for future accesses.
    mov x9, x0

    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop 8

    // Configure GPIO18 as an output.
    // In GPIO_GPFSEL1, bits 24-26 control GPIO18. Set these to 001 for output.
    ldr w1, [x0, #GPIO_GPFSEL1]
    bic w1, w1, #(7 << 24)      // Clear bits 24-26 for GPIO18
    orr w1, w1, #(1 << 24)      // Set bit 24 (001: output)
    str w1, [x0, #GPIO_GPFSEL1]

    // ---------- Melody Playback Setup ----------
    // Load the pointer to the melody table.
    ldr x20, =melody
    // Total number of note entries is 69 (as defined by the table).
    mov x21, #69              
    // Initialize note index to 0.
    mov x22, #0
    add xzr,xzr,xzr //nop 16

melody_loop:
    cmp x22, x21
    b.ge end_melody          // If index >= total notes, finish playback

    // Each note entry is 16 bytes (2 x .quad values).
    // Compute the address for the current note: x20 + (x22 << 4)
    mov x12, x22
    lsl x12, x12, #4         // x12 = x22 * 16
    add x12, x20, x12        // x12 now points to the current note's entry

    // Load the half‑period delay for this note into x10.
    ldr x10, [x12, #0]
    // Load the toggle count for this note into x11 (offset 8 bytes).
    ldr x11, [x12, #8]

    // ---------- Check for Rest ----------
    cmp x10, #0 //24
    beq rest_loop            // If half‑period = 0, this is a rest (pause)



toggle_loop:
    // ---------- Pulse Generation for the Note ----------
    // Set GPIO18 high.
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop 32
    mov w1, #1
    lsl w1, w1, #18         // Bit mask for GPIO18 (bit 18)
    str w1, [x9, #GPIO_GPSET0]

    // Delay for the half‑period.
    mov x0, x10
    bl delay

    // Set GPIO18 low.
    mov w1, #1
    lsl w1, w1, #18 
    str w1, [x9, #GPIO_GPCLR0] //40


    // Delay again for the half‑period.
    mov x0, x10
    bl delay

    // Decrement the toggle count.
    subs x11, x11, #1
    b.gt toggle_loop        // If toggle count > 0, repeat this note's cycle

    b next_note             // Done with this note, go to next 36

rest_loop:
    // ---------- Silent Delay (Rest) ----------
    mov x0, x11             // Use toggle count as delay multiplier
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop 48
delay_rest:
    bl delay
    subs x0, x0, #1
    b.gt delay_rest

next_note:
    add x22, x22, #1        // Increment the note index
    b melody_loop

end_melody:
    // End of melody: hang in an infinite loop.
    b end_melody
    add xzr,xzr,xzr //nop
    add xzr,xzr,xzr //nop 56

// ---------- Improved Delay Subroutine ----------
// Input: x0 = delay counter
// The subroutine checks if the counter is zero and uses a NOP to ensure
// constant cycle cost for each iteration.
delay:
    cbz x0, delay_done      // If counter is zero, exit delay
delay_loop:
    nop                     // No-operation for constant cycle timing
    subs x0, x0, #1         // Decrement the counter
    b.ne delay_loop         // Repeat until counter reaches zero
delay_done:
    ret                     // Return to caller

// ---------- Infinite Loop for Cores 1-3 ----------
CoreLoop:
    b CoreLoop //49

// ---------- Melody Table (Data Section) ----------
// Ensure proper alignment for .quad values.

    // Line 1: D, (rest), D, E, F, A, G, A, C, D, E, F, E, G, A, G, F
.align 3
melody:
    .quad 10230, 74    // D
    .quad 1, 25000    // rest
    .quad 10230, 74    // D
    .quad 9100, 83    // E
    .quad 8650, 87    // F
    .quad 6800, 110    // A
    .quad 7700, 98    // G
    .quad 6800, 110    // A
    .quad 11500, 65    // C
    .quad 10230, 74    // D
    .quad 9100, 83    // E
    .quad 8650, 87    // F
    .quad 9100, 83    // E
    .quad 7700, 98    // G
    .quad 6800, 110    // A
    .quad 7700, 98    // G
    .quad 8650, 87    // F
    .quad 1, 25000    // rest
    .quad 8650, 87    // F
    .quad 1, 25000    // rest
    .quad 8650, 87    // F
    .quad 1, 25000    // rest
    .quad 8650, 87    // F
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 7700, 98    // G
    .quad 8650, 87    // F
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 7700, 98    // G
    .quad 6800, 110    // A
    .quad 7700, 98    // G
    .quad 8650, 87    // F
    .quad 1, 25000    // rest
    .quad 8650, 87    // F
    .quad 1, 25000    // rest
    .quad 8650, 87    // F
    .quad 1, 25000    // rest
    .quad 8650, 87    // F
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 7700, 98    // G
    .quad 8650, 87    // F
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 10800, 69    // C#
    .quad 1, 25000    // rest
    .quad 10800, 69    // C#
    .quad 1, 25000    // rest
    .quad 10800, 69    // C#
    .quad 8650, 87    // F
    .quad 1, 25000    // rest
    .quad 8650, 87    // F
    .quad 1, 25000    // rest
    .quad 8650, 87    // F
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 7700, 98    // G
    .quad 8650, 87    // F
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 1, 25000    // rest
    .quad 6800, 110    // A
    .quad 7700, 98    // G
    .quad 11500, 65    // C
    .quad 7700, 98    // G
    .quad 10800, 69    // C#
    .quad 10230, 74    // D
   