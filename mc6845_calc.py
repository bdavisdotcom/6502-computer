# 80 by 25
characterWidth          = 8
characterHeight         = 16
nrOfTerminalRows        = 30
emptyScanLines          = 0
totalPixelsPerLine      = 800
activePixels            = 640
totalLines              = 525
activeLines             = 480
cursorStartAddress      = 0
cursorEndAddress        = 0
cursorType              = 0xC0  # Slow blinking cursor
dotClock                = 25175000

###

characterClock          = dotClock // 8
pixelTime               = 1 / dotClock
lineTime                = pixelTime * totalPixelsPerLine
totalCharactersPerLine  = totalPixelsPerLine // characterWidth
activeCharactersPerLine = activePixels // characterWidth
N                       = int(totalLines / (characterHeight + emptyScanLines))

R0  = int(totalCharactersPerLine - 1)
R1  = int(activeCharactersPerLine)
R3  = int(round((R0 - R1) / 3))
R2  = int(round(R1 + (R3 / 2)))
R4  = N - 1
R5  = totalLines % (characterHeight + emptyScanLines)
R6  = nrOfTerminalRows
R7  = int((R4 - 1) - ((16 - R5) / (characterHeight + emptyScanLines)))
R8  = 0
R9  = characterHeight + emptyScanLines - 1
R10 = cursorStartAddress + cursorType
R11 = cursorEndAddress   + cursorType
R12 = -1    # To start from video RAM address 0x0000
R13 = -1    # To start from video RAM address 0x0000
R14 = -1    # To start at position (0, 0)
R15 = -1    # To start at position (0, 0)

print("========================================")

print("dotClock                :", dotClock, "Hz")
print("characterClock          :", characterClock, "Hz")
print("pixelTime               : {:0.2f} ns".format(pixelTime * 1000000000))
print("lineTime                : {:0.2f} ms".format(lineTime * 1000000))
print("totalCharactersPerLine  : {:d} characters".format(totalCharactersPerLine))
print("activeCharactersPerLine : {:d} characters".format(activeCharactersPerLine))
print("characterWidth          : {:d}".format(characterWidth))
print("characterHeight         : {:d}".format(characterHeight))
print("nrOfTerminalRows        : {:d}".format(nrOfTerminalRows))
print("emptyScanLines          : {:d}".format(emptyScanLines))
print("N                       : {:d}".format(N))

print("========================================")

print("RO  : {:3d} (0x{:2x}) - Nr of Horizontal Characters Total.".format(R0, R0))
print("R1  : {:3d} (0x{:2x}) - Nr of Horizontal Characters Displayed.".format(R1, R1))
print("R2  : {:3d} (0x{:2x}) - Horizontal Sync Position.".format(R2, R2))
print("R3  : {:3d} (0x{:2x}) - Sync width.".format(R3, R3))
print("R4  : {:3d} (0x{:2x}) - Vertical Total.".format(R4, R4))
print("R5  : {:3d} (0x{:2x}) - Vertical Total Adjustment.".format(R5, R5))
print("R6  : {:3d} (0x{:2x}) - Nr of Vertical Characters Displayed.".format(R6, R6))
print("R7  : {:3d} (0x{:2x}) - Vertical Sync Position (might need manual fine tuning).".format(R7, R7))
print("R8  : {:3d} (0x{:2x}) - Interlace Mode.".format(R8, R8))
print("R9  : {:3d} (0x{:2x}) - Max Scanline Address.".format(R9, R9))
print("R10 : {:3d} (0x{:2x}) - Cursor Start Scan Line.".format(R10, R10))
print("R11 : {:3d} (0x{:2x}) - Cursor Stop Scan Line.".format(R11, R11))
print("R12 : {:3d} (0x{:2x}) - Start Address (High). Real start address is 0x0000.".format(R12, R12 & (2**8-1)))
print("R13 : {:3d} (0x{:2x}) - Start Address (Low). Real start address is 0x0000.".format(R13, R13 & (2**8-1)))
print("R14 : {:3d} (0x{:2x}) - Cursor Start Address (High). Cursor will be at position (0, 0).".format(R14, R14 & (2**8-1)))
print("R15 : {:3d} (0x{:2x}) - Cursor Start Address (Low). Cursor will be at position (0, 0).".format(R15, R15 & (2**8-1)))

print("========================================")