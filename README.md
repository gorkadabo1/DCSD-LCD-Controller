# FPGA LCD Controller - DE1-SoC with LT24 Display

A digital system designed to control an LT24 LCD display using an Intel DE1-SoC FPGA board. This project implements drawing primitives, screen clearing, UART image transfer, and a simple animation system.


## Overview

This project was developed for the Digital Systems Design and Construction course (DCSD). The system controls a 240x320 pixel LT24 LCD display through custom VHDL modules, enabling:

- **Screen Clear**: Fill the entire display with a selected color
- **Diagonal Line Drawing**: Draw a diagonal line from the top-left corner
- **UART Image Transfer**: Receive and display images sent from a PC via serial communication (115200 baud)
- **Video Animation**: Display a moving square animation at 24 FPS

## Architecture

The system is divided into five interconnected modules:

```
                    +-------------+
                    |  LT24_Init  |  Screen initialization
                    +------+------+
                           |
    +----------------------+----------------------+
    |                      |                      |
+---v----+          +------v------+        +------v------+
|  UART  |--------->|  REC_PIXEL  |------->| LCD_DRAWING |
+--------+          +-------------+        +------+------+
  Serial               Pixel                     |
  receiver             assembler                 |
                                          +------v------+
                                          |  LCD_CTRL   |
                                          +-------------+
                                            Low-level
                                            LCD commands
```

### Module Descriptions

| Module | Description |
|--------|-------------|
| **LT24_Init** | Handles LCD initialization sequence and provides the interface to the physical display |
| **LCD_CTRL** | Executes low-level operations: cursor positioning and pixel drawing via LCD commands (0x2A, 0x2B, 0x2C) |
| **LCD_DRAWING** | High-level controller that orchestrates the four main functionalities and coordinates other modules |
| **UART** | Receives serial data at 115200 baud, handling timing synchronization (434 clock cycles per bit at 50MHz) |
| **REC_PIXEL** | Assembles two 8-bit UART transfers into a single 16-bit RGB565 pixel value |

## Hardware Requirements

- **FPGA Board**: Terasic DE1-SoC (Intel Cyclone V)
- **Display**: Terasic LT24 LCD Module (240x320, 16-bit color)
- **Connection**: LT24 connected via GPIO-0, UART via GPIO-1

## Project Structure

```
DCSD-LCD-Controller/
├── README.md
├── docs/
│   └── UP _ UC_Diagrams.pdf
│   └── fpga_lcd_controller_report.pdf
├── src/
│   ├── LCD_CTRL.vhd
│   ├── LCD_DRAWING.vhd
│   ├── UART.vhd
│   ├── REC_PIXEL.vhd
│   ├── DE1SOC_LCDLT24_v1.vhd        # Top-level entity
│   ├── hex_7seg.vhd
│   └── lcd_setup/
│       ├── Init128rom_pkg.vhd
│       ├── LT24InitLCD.vhd
│       ├── LT24InitReset.vhd
│       ├── LT24SetUp.vhd
│       └── romsinc.vhd
├── testbench/
│   ├── TB_LCD_CTRL.vhd
│   ├── TB_LCD_DRAWING.vhd
│   ├── TB_UART.vhd
│   └── TB_REC_PIXEL.vhd
└── constraints/
    ├── DE1SOC_LCDLT24_v1.qsf
    └── DE1SOC_LCDLT24_v1.sdc
```

## Usage

### Button Controls

| Button | Function |
|--------|----------|
| KEY0 | Reset |
| KEY1 | Draw image (UART mode) |
| KEY2 | Clear screen |
| KEY3 + SW9=0 | Draw diagonal line |
| KEY3 + SW9=1 | Play video animation |

### Color Selection (SW2-SW0)

| Switch Value | Color |
|--------------|-------|
| 000 | Black |
| 001 | White |
| 010 | Red |
| 011 | Green |
| 100 | Blue |
| 101 | Brown |
| 110 | Orange |
| 111 | Pink |

### Sending Images via UART

1. Open Tera Term (or similar terminal)
2. Select the appropriate COM port (usually COM3)
3. Go to File → Send
4. Select your image file
5. **Important**: Check the "Binary" option before sending

Images must be in raw RGB565 format, 240x320 pixels (153,600 bytes).

## Technical Details

### Timing

- **System Clock**: 50 MHz (20 ns period)
- **UART Baud Rate**: 115200
- **Cycles per UART bit**: 434 (50MHz / 115200)
- **Video FPS**: ~24 (achieved via 525,000 cycle delay between frames)

### Display Specifications

- **Resolution**: 240 x 320 pixels
- **Color Depth**: 16-bit (RGB565)
- **Total Pixels**: 76,800

### State Machines

The project uses finite state machines (FSM) for each module:
- LCD_CTRL: 14 states
- LCD_DRAWING: 28 states
- UART: 7 states
- REC_PIXEL: 6 states

## Building the Project

1. Open Intel Quartus Prime
2. Open the project file `DE1SOC_LCDLT24_v1.qpf`
3. Compile the project (Processing → Start Compilation)
4. Program the FPGA (Tools → Programmer)

### Simulation

1. Open ModelSim
2. Compile the VHDL files and corresponding testbenches
3. Run the simulation for the desired module

## Design Methodology

1. **Control Unit Design**: FSM diagrams for each module
2. **Process Unit Design**: Datapath with registers, counters, multiplexers, and comparators
3. **VHDL Implementation**: Behavioral description of both units
4. **Simulation**: Functional verification using ModelSim testbenches
5. **Synthesis**: Compilation and FPGA programming with Quartus
6. **Hardware Testing**: Validation on the physical DE1-SoC board

## License

This project was developed for educational purposes at the University of the Basque Country (EHU).

## Acknowledgments

- Department of Computer Architecture and Technology, Faculty of Informatics (EHU)
- Course: Digital Systems Design and Construction (DCSD), 2023-2024
