# Brad's 6502 Computer Build -- Work in progress!!!
Based on Ben Eater's design: https://eater.net. Thanks to Ben for his great videos.

Thanks to George Foot for his crtc VGA videos: https://www.youtube.com/@GeorgeFoot/videos

## What this is
This is the bios/firmware for a Ben Eater style WD 65C02 8-bit computer build with a VGA character display. This design is built with:
* TTL logic chips
* WD 65C02 processor chip
* WD 65C22 VIA
* WD 65C51N ACIA
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

### ATF22V10C
ATF22V10C plds were used for the following purposes:
* bus address decoding / glue logic
* crtc chip helper
* pixel helper
  
Code is in the /addr_decoder and /crtc_controller folders. The .doc files have the chip pinouts at the bottom of the file.

![20250812_173603](https://github.com/user-attachments/assets/84d05559-f159-402a-8e1a-f46dc62f8b88)
![20250804_120444](https://github.com/user-attachments/assets/e2e5c8dd-4128-40c7-a7a2-0bf37f97e545)
![20250812_173556](https://github.com/user-attachments/assets/0a4da1c0-c5b6-462e-b5ba-dcf7d3f7ab3e)

### Memory map
```
ACIA_DATA       = $8000
ACIA_STATUS     = $8001
ACIA_CMD        = $8002
ACIA_CTRL       = $8003
VIA           = $8100
CRTC_ADDRESS = $8900
CHAR_RAM = $9000
COLOR_RAM = $9800

```
