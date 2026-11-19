# Avalon-MM PWM Generator (Nios II, DE1)

A configurable PWM generator implemented in VHDL as an Avalon Memory-Mapped slave, with a C driver for the Nios II processor.

## Features

- Programmable period and duty cycle through two memory-mapped registers
- 50 MHz system clock (Altera DE1, Cyclone II EP2C20F484C7)

## Register Map

| Offset | Name | Description |
|--------|------|-------------|
| 0 | `PWM_REG_FREQ` | Period register. Period = `freq + 1` clock cycles |
| 1 | `PWM_REG_DUTY` | Duty register. High time in clock cycles |

## Example Configuration

A 1024-cycle period at 50% duty cycle:

```c
IOWR(AVALON_PWM_0_BASE, 0, 0x03FF);   /* period = 1024 cycles */
IOWR(AVALON_PWM_0_BASE, 1, 0x0200);   /* duty = 512 cycles (50%) */
```

With a 50 MHz clock, this gives a frequency of 50 MHz / 1024 ≈ 48.8 kHz.

## Files

- `avalon_pwm.vhd`: PWM core with Avalon-MM slave interface
- `PWM.vhd`: PWM logic
- `avalon_pwm.qsf`: Quartus II project settings and pin assignments
- `hello_world_small.c`: Nios II test program

## Build

1. Open `avalon_pwm.qsf` in Quartus II 13.0 SP1 or later.
2. In Platform Designer, add `avalon_pwm` as a custom component with an Avalon-MM slave interface and connect it to the Nios II processor, clock, and reset.
3. Assign a base address, then generate the system.
4. Compile the project and program the FPGA.
5. Build and run the C program from Nios II IDE.

## Requirements

- Quartus II 13.0 SP1 (or compatible)
- Nios II IDE
- Altera DE1 board
