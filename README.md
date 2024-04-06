# The Bomb

A serial driver POC for the ST7920 (128x64) LCD display
written in SystemVerilog, runnable on an FPGA.

![FPGA connected to LCD displaying text "WHO DO YOU THINK YOU ARE? I AM!"](https://github.com/nickorlow/the-bomb/blob/main/.images/bomb.png?raw=true)

## Requirements

- make
- python
- Intel Quartus (only if running on FPGA)
- Verilator (only if simulating)

## Changing Display text
You can change the demo text by editing `text.txt`. Each line
should be less than or equal to 16 characters long (longer lines 
will be wrapped). You should keep the number of lines to under 4 
(anything over this will be vertically wrapped).

## Simulation testing

This module can be simulated with Verilator. This is useful 
for testing quickly. If you have Verilator installed, simply 
run the below `make` command to run a simulation where signals 
from the module will be decoded:

```
make run 
```

## Running on an FPGA

This was written for and tested on a DE10-Nano Cyclone V 
board. It should work with most if not all FPGAs.

To run on an FPGA, first ensure that you have Intel 
Quartus installed. You will then want to make modificaitons 
to the `st7920_driver.qpf` and `make_cdf.sh` files. The 
necessary changes to these files will be explained in 
more detail below. 

Once you have done the above, connect your FPGA via 
JTAG and run the following `make` command:

```
make run-fpga
```

### Wiring the display

To get this to work, the display needs to be wired in the 
following configuration:

| Pin       | Connection    |
|-----------|---------------|
| VSS/GND   | GND           |
| VDD/VCC   | +5V           |
| V0        | 10k POTENTIOMETER OUTPUT / NOT CONNECTED |
| D/I or RS | +5V           |
| RW        | FPGA PIN      |
| E         | FPGA PIN      |
| DB0-DB7   | NOT CONNECTED |
| CS1/PSB   | GND           |
| CS2       | NOT CONNECTED |
| RST       | NOT CONNECTED |
| VOUT      | 10k POTENTIOMETER GND / NOT CONNECTED |
| BLA       | +5V           |
| BLK       | GND           |

V0 and VOUT only need to be connected if your display does not 
automatically manage contrast. 

FPGA PIN refers to any GPIO pin on your FPGA. When it's 
all wired up, you should have something that looks somewhat
like in the example image up above. 

The files in this build have RW mapped to `PIN_W12` and E mapped to 
`PIN_D8`. If you have a DE10-Nano, you can recreate the connections 
in the above image exactly and it should work.

```
Note: Some ST7920 displays are hardwired to only work in paralell 
mode or they may have other weird quirks. The specific display I used 
when developing this was made by Ximimark, and can be purchased at: 
https://www.amazon.com/dp/B07T5CY8PP

Note that V0/VOUT do not need to be connected on this display.
```

### Modifying st7920\_driver.qpf make\_cdf.sh 

If you have a DE10-Nano Cyclone V board, you may skip this step. 

Otherwise, go open this project in Quartus and configure the project 
so that it builds and can be programmed onto your FPGA. When you do that, 
the `qpf` file will be automatically modified. You will then want to copy
the text from `output_files/st7920_driver.cdf` and put it into the echoed 
text in `make_cdf.sh`.

## Misc

I used this datasheet a lot when developing this, it may be useful to 
you: [https://www.waveshare.com/datasheet/LCD_en_PDF/ST7920.pdf](https://www.waveshare.com/datasheet/LCD_en_PDF/ST7920.pdf)
