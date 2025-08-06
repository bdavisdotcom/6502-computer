;RO  :  99 (0x63) - Nr of Horizontal Characters Total.
;R1  :  80 (0x50) - Nr of Horizontal Characters Displayed.
;R2  :  83 (0x52) - Horizontal Sync Position.
;R3  :   12 (0x 0c) - Sync width.
;R4  :  64 (0x1f) - Vertical Total.
;R5  :   5 (0x d) - Vertical Total Adjustment.
;R6  :  25 (0x1e) - Nr of Vertical Characters Displayed.
;R7  :  61 (0x1f) - Vertical Sync Position (might need manual fine tuning).
;R8  :   0 (0x 0) - Interlace Mode.
;R9  :   7 (0x f) - Max Scanline Address.
;R10 : 0 - Cursor Start Scan Line.  Should be 0?
;R11 : 0 - Cursor Stop Scan Line.   Should be 0?
;R12 :  0 - Start Address (High). Real start address is 0x0000.
;R13 :  0 - Start Address (Low). Real start address is 0x0000.
;R14 :  0 - Cursor Start Address (High). Cursor will be at position (0, 0).
;R15 :  0 - Cursor Start Address (Low). Cursor will be at position (0, 0).
;                    r0   r1   r2   r3   r4   r5   r6   r7   r8   r9   r10  r11  r12  r13  r14  r15
CRTC_SETTINGS: .byte $31, $28, $28, $06, $1f, $0d, $1e, $1e, $00, $0f, $00, $00, $00, $00, $00, $00

CRTC_ADDRESS = $8900
CRTC_REGISTER = $8901
CHAR_RAM = $9000
CHAR_RAM_END = $94B0
CHAR_RAM_DEFAULT_VALUE = $00
COLOR_RAM = $9800
COLOR_RAM_END = $9CB0
COLOR_RAM_DEFAULT_VALUE = $0f

CURSOR_ADDRESS_PTR = $94B0

; Alters A, X, Y registers!
INIT_CRTC:
    ldx #$00    ; crtc register address
    lda #<COLOR_RAM
    sta CURSOR_ADDRESS_PTR
    lda #>COLOR_RAM
    sta CURSOR_ADDRESS_PTR+1

@settings_loop:
    stx CRTC_ADDRESS     ; set crtc address
    lda CRTC_SETTINGS,x ; lda with setting #y from the CRTC_SETTINGS bytes
    sta CRTC_REGISTER   ; store in the crtc register pointed to by the address
    sta $0400,x
    inx
    cpx #$10            ; decimal 16
    bne @settings_loop

; Now set color ram to $0f (just white foreground text)

    lda #<COLOR_RAM
    sta $10

    lda #>COLOR_RAM
    sta $11

    lda #COLOR_RAM_DEFAULT_VALUE
    sta $12

    lda #<COLOR_RAM_END ; stop address
    sta $13
    lda #>COLOR_RAM_END ; end address
    STA $14

    jsr @init_video_ram

; Now set char ram to $00 (empty)

    lda #<CHAR_RAM
    sta $10

    lda #>CHAR_RAM
    sta $11

    lda #CHAR_RAM_DEFAULT_VALUE
    sta $12

    lda #<CHAR_RAM_END ; stop address
    sta $13
    LDA #>CHAR_RAM_END
    STA $14

    jsr @init_video_ram

    rts

; Modifies: A, Y regs
; Expects: 
;   $10, $11 beginning memory address
;   $12 value to write to each address
;   $13, $14 ending memory address, non-inclusive
@init_video_ram:
    lda $12 ; load a with value to write to memory
@loop:
    sta ($10) ; store the value to memory pointed to by $10
    inc $10 ; increment value at memory location $10
    ldy $10 ; load y with value at $10
    cpy #$00 ; compare y with 0 (rollover from 255 to 0 check)
    beq @inc_high_byte ; if rolled over, increment the high byte of the address
@check_if_done:    
    ldy $11 ; load y with value at $11
    cpy $14 ; compare with end address stored in $14
    bne @loop ; if not equal, go back to the loop
    ldy $10 ; if $11 did match $14 -- load y with low address byte at $10
    cpy $13 ; see if $10 matches $13
    beq @init_video_ram_done ; if it does we are done ($10 == $13 and $11 = $14)
    jmp @loop ; no, not done, go back to the loop
@inc_high_byte:
    inc $11; increment the high address byte, because low byte rolled over to 255
    jmp @check_if_done ; check if we're done or not
@init_video_ram_done:
    rts

; A - register contains ascii character code to write to memory
; location pointed at by VIDEO_CURSOR_PTR
VIDEO_WRITE_CHAR:
    phx
    ldx #<CURSOR_ADDRESS_PTR
    stx $10
    ldx #>CURSOR_ADDRESS_PTR
    stx $11
    sta ($10)

    inc CURSOR_ADDRESS_PTR
    ldx CURSOR_ADDRESS_PTR
    cpx #$00
    bne @check_at_max_video_ram
    inc CURSOR_ADDRESS_PTR+1
    ldx CURSOR_ADDRESS_PTR+1
@check_at_max_video_ram:
    ldx CURSOR_ADDRESS_PTR+1
    cpx #>CHAR_RAM_END
    bne @exit_video_write_char
    ldx CURSOR_ADDRESS_PTR
    cpx #<CHAR_RAM_END
    bne @exit_video_write_char
    lda #<CHAR_RAM
    sta CURSOR_ADDRESS_PTR
    lda #>CHAR_RAM
    sta CURSOR_ADDRESS_PTR+1
@exit_video_write_char:
    plx
    rts

; back the cursor up 1 byte in the video ram
VIDEO_CURSOR_BACKSPACE:
    phx
    dec CURSOR_ADDRESS_PTR
    ldx CURSOR_ADDRESS_PTR
    cpx #$ff
    bne @exit_video_cursor_backspace
    dec CURSOR_ADDRESS_PTR+1
@exit_video_cursor_backspace:
    plx
    rts
