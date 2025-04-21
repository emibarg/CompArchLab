/*********************************************************************************************
*   main.s
*   Organización y arquitectura de computadoras - UCC
*   2025
*
*   This bare‑metal ARMv8 program for the Raspberry Pi 3 configures GPIO18 as an output,
*   then plays a melody consisting of the notes: DO, RE, MI, FA, SOL, LA, SI.
*
*   Each note is specified by two values:
*     • A half‑period delay value (controls the frequency/pitch).
*     • A toggle count (controls how many on/off pulses are produced, roughly giving a 3‑second tone).
*
*   Melody Table:
*     DO: 261 Hz    → half‑period: 14300, toggle count: 1566
*     RE: 293 Hz    → half‑period: 12600, toggle count: 1758
*     MI: 329 Hz    → half‑period: 11200, toggle count: 1974
*     FA: 349 Hz    → half‑period: 10600, toggle count: 2094
*     SOL:392 Hz    → half‑period:  9400, toggle count: 2352
*     LA: 440 Hz    → half‑period:  8500, toggle count: 2640
*     SI: 493 Hz    → half‑period:  7600, toggle count: 2958
**********************************************************************************************/
.text

.equ PERIPHERAL_BASE, 0x3F000000    // Peripheral Base Address
.equ GPIO_BASE, 0x200000            // GPIO Base Address
.equ GPIO_GPFSEL1, 0x4              // GPIO Function Select 1 offset
.equ GPIO_GPSET0, 0x1C              // GPIO Pin Output Set 0 offset
.equ GPIO_GPCLR0, 0x28              // GPIO Pin Output Clear 0 offset

.global _start
_start:
    // ---------- Core Initialization ----------
    // Get core ID. Only core 0 continues; cores 1-3 go into an infinite loop.
    mrs x0, MPIDR_EL1          // Read Multiprocessor Affinity Register
    ands x0, x0, #3            // Extract core ID bits (0..1)
    b.ne CoreLoop              // If core ID != 0, branch to infinite loop

    // ---------- GPIO Setup ----------
    // Compute the GPIO base pointer:
    ldr x0, =PERIPHERAL_BASE
    add x0, x0, #GPIO_BASE     // x0 now points to the GPIO registers
    // Save the GPIO base pointer in x9 for future accesses.
    mov x9, x0

    // Configure GPIO18 as an output.
    // In GPIO_GPFSEL1, bits 24-26 control GPIO18. Setting these to 001 makes it an output.
    ldr w1, [x0, #GPIO_GPFSEL1]
    bic w1, w1, #(7 << 24)     // Clear bits 24-26
    orr w1, w1, #(1 << 24)     // Set bit 24 (001: output)
    str w1, [x0, #GPIO_GPFSEL1]

    // ---------- Melody Playback Setup ----------
    // Load the pointer to the melody table.
    ldr x20, =melody
    // Set the total number of notes in the melody.
    mov x21, #7               // There are 7 note entries
    // Initialize note index to 0.
    mov x22, #0

melody_loop:
    cmp x22, x21
    b.ge end_melody         // If index >= number of notes, end melody

    // Each note entry is 16 bytes long (2 x .quad values):
    // Compute the address of the note entry: x20 + (x22 << 4)
    mov x12, x22
    lsl x12, x12, #4         // x12 = x22 * 16
    add x12, x20, x12        // x12 now points to the current note entry

    // Load the half‑period delay (first quad) into x10.
    ldr x10, [x12, #0]
    // Load the toggle count (second quad) into x11. (Offset 8 bytes)
    ldr x11, [x12, #8]

toggle_loop:
    // ---------- Pulse Generation for the Note ----------
    // Set GPIO18 high.
    mov w1, #1
    lsl w1, w1, #18         // Prepare bit mask for GPIO18 (bit 18)
    str w1, [x9, #GPIO_GPSET0]

    // Call the delay subroutine with the half‑period delay.
    mov x0, x10
    bl delay

    // Set GPIO18 low.
    mov w1, #1
    lsl w1, w1, #18         // Prepare bit mask for GPIO18
    str w1, [x9, #GPIO_GPCLR0]

    // Delay again with the same half‑period.
    mov x0, x10
    bl delay

    // Decrement the toggle count.
    subs x11, x11, #1
    b.gt toggle_loop        // Repeat if toggle count > 0

    // ---------- Next Note ----------
    add x22, x22, #1        // Increment note index
    b melody_loop

end_melody:
    // End of melody: hang in an infinite loop.
    b end_melody

// ---------- Simple Delay Subroutine ----------
// Input: x0 = delay counter
// This loop simply decrements x0 until it reaches zero.
delay:
    subs x0, x0, #1
    b.ne delay
    ret

// ---------- Infinite Loop for Cores 1-3 ----------
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