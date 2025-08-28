# Brad's 6502 Computer Build -- Work in progress!!!
Based on Ben Eater's design: https://eater.net. Thanks to Ben for his great videos.

Thanks to George Foot for his crtc VGA videos: https://www.youtube.com/@GeorgeFoot/videos

Thanks to https://github.com/rweather/stackable-6502-computer for his design and samples of his PCBs!

## What this is
This is the bios/firmware for a Ben Eater style WD 65C02 8-bit computer build with a VGA character display. This design is built with:
* TTL logic chips
* WD 65C02 processor chip
* WD 65C22 VIA
* WD 65C51N ACIA
* MAX232 RS-232
* ROM chips
* sRAM chips (both standard and dual-port variety)
* ATF22V10C PLD's.
* Motorola MC68B45 CRT controller
* and assorted others

## Kicad schematics coming soon

## Building the code
You will need to install cc65 suite
https://github.com/cc65/cc65
Run ```./make.sh```

### Memory map
```
ROM_CE =      ADDRESS_IO:[A000..FFFF];      /* (A15 & A14) # (A15 & !A14 & A13); */
COLOR_RAM_CE= ADDRESS_IO:[9800..9FFF] & CLK;      /* CLK & A15 & !A14 & !A13 & A12; */
CHAR_RAM_CE = ADDRESS_IO:[9000..97FF] & CLK;      /* CLK & A15 & !A14 & !A13 & !A12 & A11; */
CRTC_CE =     ADDRESS_IO:[8900..89FF];      /*  A15 & !A14 & !A13 & !A12 & !A11 & A10 & A09 & A08; */
VIA0_CE =     ADDRESS_IO:[8100..81FF];      /*  A15 & !A14 & !A13 & !A12 & !A11 & !A10 & !A09 & A08; */
ACIA_CE =     ADDRESS_IO:[8000..80FF];      /* A15 & !A14 & !A13 & !A12 & !A11 & !A10 & !A09 & !A08; */
RAM_CE =      ADDRESS_IO:[0000..7FFF] & CLK; /* !A15 & CLK; */
```

### ATF22V10C
ATF22V10C plds were used for the following purposes:
* bus address decoding / glue logic
* crtc chip helper
* pixel helper
  
Code is in the /addr_decoder and /crtc_controller folders. The .doc files have the chip pinouts at the bottom of the file.

The display glitches shown in the images have since been corrected.

![20250812_173603](https://github.com/user-attachments/assets/84d05559-f159-402a-8e1a-f46dc62f8b88)
![20250804_120444](https://github.com/user-attachments/assets/e2e5c8dd-4128-40c7-a7a2-0bf37f97e545)
![20250812_173556](https://github.com/user-attachments/assets/0a4da1c0-c5b6-462e-b5ba-dcf7d3f7ab3e)

### VGA rough shematic drawing
![vga schematic](https://github.com/user-attachments/assets/8ee64368-fef2-42fd-a463-b9f33bb27bad)



