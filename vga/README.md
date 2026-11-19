# Avalon-MM VGA Color Bar Controller (Nios II, DE1)

A 640×480 @ 60 Hz VGA controller implemented in VHDL with an Avalon Memory-Mapped palette interface. The processor selects eight 12-bit colors, which are displayed as vertical bars on a VGA monitor.

## Features

- 640×480 @ 60 Hz timing (800×525 total)
- 25 MHz pixel clock generated from the 50 MHz system clock by division by 2
- Eight 12-bit RGB colors (4 bits per channel) in memory-mapped registers
- Eight vertical color bars, 80 pixels each

## Timing

| Parameter | Value |
|-----------|-------|
| Visible area | 640 × 480 |
| Horizontal total | 800 pixels |
| Horizontal sync | 96 pixels (active low) |
| Vertical total | 525 lines |
| Vertical sync | 2 lines (active low) |

## Register Map

Each register is a 32-bit word. Only bits [11:0] are used.

| Offset | Index | Description |
|--------|-------|-------------|
| 0x00 | 0 | Color of bar 0 (RGB 4-4-4) |
| 0x04 | 1 | Color of bar 1 |
| ... | ... | ... |
| 0x1C | 7 | Color of bar 7 |

Color format: `0xRGB`, where R = bits [11:8], G = bits [7:4], B = bits [3:0].

Examples: `0xF00` = red, `0x0F0` = green, `0x00F` = blue, `0xFFF` = white.

## Example Usage

```c
IOWR_32DIRECT(AVALON_VGA_0_BASE, 0 * 4, 0xF00);   /* bar 0: red */
IOWR_32DIRECT(AVALON_VGA_0_BASE, 1 * 4, 0x0F0);   /* bar 1: green */
```

## Files

- `avalon_vga.vhd`: VGA controller with Avalon-MM slave interface
- `VGA.vhd`: Top-level entity that connects the Qsys system to the VGA pins
- `VGA2.qsf`: Quartus II project settings and DE1 pin assignments
- `vga_color_bars.c`: Nios II program that cycles the color bars

## Build

1. Open `VGA2.qsf` in Quartus II 13.0 SP1 or later.
2. In Platform Designer, add `avalon_vga` as a custom component with an Avalon-MM slave interface. Connect it to the Nios II processor, clock (50 MHz), and reset. Export the VGA signals as a conduit.
3. Assign base addresses, then generate the system. Confirm that the generated `system_vga.qip` is listed in the project.
4. Compile the project and program the FPGA.
5. Connect a VGA monitor to the DE1 VGA port.
6. Build and run `vga_color_bars.c` from Nios II IDE.

## Requirements

- Quartus II 13.0 SP1 (or compatible)
- Nios II IDE
- Altera DE1 board and VGA monitor
