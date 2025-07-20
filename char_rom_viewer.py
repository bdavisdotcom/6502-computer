#!/usr/bin/env python

from PIL import Image, ImageDraw

image=Image.new("1",[256,256])

# TRS_80 Model I
fontfile = open("IBM_VGA_8x8.bin", "rb").read()
ROM_ROWS=8
NUM_CHARS=128
OUTFILE="ibm.png"

# TRS_80 Model III ; this ROM has twice as many characters
# fontfile = open("ROMS/trs80m3/8044316a.u36", "rb").read()
# ROM_ROWS=8
# NUM_CHARS=256
# OUTFILE="TRS80MODELIII_CHARS.PNG"

# Commodore PET, uses same settings as Model III
# fontfile = open("characters-2.901447-10.bin", "rb").read()
# ROM_ROWS=8
# NUM_CHARS=256
# OUTFILE="PETchars.png"

# Example for a 4-bit row font
#fontfile = open("ROMS/m2/8043316.u9", "rb").read()
#ROM_ROWS=16
#NUM_CHARS=128
#OUTFILE="TRS80MODELII_CHARS.PNG"

gridposx=0
gridposy=0

d=ImageDraw.Draw(image)

for fontchar in range (NUM_CHARS):
    for y in range(ROM_ROWS):
        for bitpos in range(8):
            if (fontfile[(fontchar*ROM_ROWS)+y] >> bitpos & 1):
                d.point([(gridposx+(7-bitpos)),(gridposy+y)],1)
    gridposx=gridposx+8
    if gridposx > 255:
        gridposx=0
        gridposy=gridposy+ROM_ROWS

# image.show()
image.save(OUTFILE)