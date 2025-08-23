;RO  : Nr of Horizontal Characters Total.
;R1  : Nr of Horizontal Characters Displayed.
;R2  : Horizontal Sync Position.
;R3  : Sync width.
;R4  : Vertical Total.
;R5  : Vertical Total Adjustment.
;R6  : Nr of Vertical Characters Displayed.
;R7  : Vertical Sync Position (might need manual fine tuning).
;R8  : Interlace Mode.
;R9  : Max Scanline Address.
;R10 : Cursor Start Scan Line.  Should be 0?
;R11 : Cursor Stop Scan Line.   Should be 0?
;R12 : Start Address (High). Real start address is 0x0000.
;R13 : Start Address (Low). Real start address is 0x0000.
;R14 : Cursor Start Address (High). Cursor will be at position (0, 0).
;R15 : Cursor Start Address (Low). Cursor will be at position (0, 0).

;                    r0   r1   r2   r3   r4   r5   r6   r7   r8   r9   r10  r11  r12  r13  r14  r15
CRTC_SETTINGS: .byte $31, $28, $29, $06, $1f, $0d, $19, $1d, $00, $0f, $60, $0f, $00, $00, $00, $00
CRTC_CURSOR_H = $0E ; REG 14
CRTC_CURSOR_L = $0F ; REG 15
CRTC_START_H = $0C
CRTC_START_L = $0D
CRTC_ADDRESS = $8900
CRTC_REGISTER = $8901
CHAR_RAM = $9000
CHAR_RAM_END = $9800
CHAR_RAM_DEFAULT_VALUE = $00
COLOR_RAM = $9800
COLOR_RAM_END = $A000
COLOR_RAM_DEFAULT_VALUE = $1B
LINE_NUM_CHARS = $28 ; 40 chars per line
MAX_LINE = $19 ; 25 lines, so 24 is last line (0-24)

; Alters A, X, Y registers!
INIT_CRTC:
    ldx #$00    ; crtc register address

@settings_loop:
    stx CRTC_ADDRESS     ; set crtc address
    lda CRTC_SETTINGS,x ; lda with setting #y from the CRTC_SETTINGS bytes
    sta CRTC_REGISTER   ; store in the crtc register pointed to by the address
    sta $0400,x
    inx
    cpx #$10            ; decimal 16
    bne @settings_loop
    ; Now clear char and color ram
    jsr VIDEO_CLEAR
    rts

VIDEO_CLEAR:
    pha
    phy

    ;clear char ram
    lda #CHAR_RAM_DEFAULT_VALUE
    sta SCRATCH_DATA_RAM
    lda #<CHAR_RAM
    sta CURSOR_ADDRESS_PTR
    lda #>CHAR_RAM
    sta CURSOR_ADDRESS_PTR+1
    lda #<CHAR_RAM_END
    sta SCRATCH_ADDR_RAM
    lda #>CHAR_RAM_END
    sta SCRATCH_ADDR_RAM+1
    jsr @video_clear_ram

    lda #COLOR_RAM_DEFAULT_VALUE
    sta SCRATCH_DATA_RAM
    lda #<COLOR_RAM
    sta CURSOR_ADDRESS_PTR
    lda #>COLOR_RAM
    sta CURSOR_ADDRESS_PTR+1
    lda #<COLOR_RAM_END
    sta SCRATCH_ADDR_RAM
    lda #>COLOR_RAM_END
    sta SCRATCH_ADDR_RAM+1
    jsr @video_clear_ram    

    lda #<CHAR_RAM
    sta CURSOR_ADDRESS_PTR
    lda #>CHAR_RAM
    sta CURSOR_ADDRESS_PTR+1

    lda #$00
    sta CURSOR_X_POS
    sta CURSOR_Y_POS
    sta VIDEO_SCROLL_POS
    sta VIDEO_SCROLL_POS+1

    ; sets MC6845 cursor pos
    LDA #CRTC_CURSOR_L
    STA CRTC_ADDRESS
    LDA CURSOR_ADDRESS_PTR
    STA CRTC_REGISTER

    LDA #CRTC_CURSOR_H
    STA CRTC_ADDRESS
    LDA CURSOR_ADDRESS_PTR+1
    SEC
    SBC #>CHAR_RAM
    STA CRTC_REGISTER    

    ply
    pla

    rts

; Uses A, Y regs
; Also uses 
;   CURSOR_ADDRESS_PTR - used to calculate address to clear
;   SCRATCH_ADDR_RAM - end address to clear to
;   SCRATCH_DATA_RAM - value to set ram to 
@video_clear_ram:
    lda SCRATCH_DATA_RAM
@loop:
    sta (CURSOR_ADDRESS_PTR)
    inc CURSOR_ADDRESS_PTR
    beq @inc_high_byte
@check_if_done:
    ldy CURSOR_ADDRESS_PTR+1
    cpy SCRATCH_ADDR_RAM+1
    bne @loop
    ldy CURSOR_ADDRESS_PTR
    cpy SCRATCH_ADDR_RAM
    beq @clear_done
    jmp @loop
@inc_high_byte:
    inc CURSOR_ADDRESS_PTR+1
    jmp @check_if_done
@clear_done:
    rts

; A contains a positive number of bytes to add to current position
; Since we are only adding 1 byte, increase can only be 256 or less
MOVE_CURSOR_POSITION:
    PHX
    PHA
    LDA #CRTC_CURSOR_L
    STA CRTC_ADDRESS
    ; LDA CRTC_REGISTER
    PLA
    CLC
    ADC CRTC_REGISTER
    BCC @no_rollover

    LDX #CRTC_CURSOR_H
    STX CRTC_ADDRESS
    LDX CRTC_REGISTER
    INX
    STX CRTC_REGISTER

    LDX #CRTC_CURSOR_L
    STX CRTC_ADDRESS
@no_rollover:
    STA CRTC_REGISTER
    PLX
    RTS

CURSOR_BACKSPACE:
    LDA #CRTC_CURSOR_L
    STA CRTC_ADDRESS
    LDA CRTC_REGISTER
    DEC
    STA CRTC_REGISTER
    CMP #$FF
    BNE @no_rollover
    LDA #CRTC_CURSOR_H
    STA CRTC_ADDRESS
    LDA CRTC_REGISTER
    DEC
    STA CRTC_REGISTER
@no_rollover:
    RTS

; clear current line
; assumes cursor address is at beginning of the line
VIDEO_CLEAR_LINE:
    ;find beginning of line...
    lda CURSOR_ADDRESS_PTR
    sta SCRATCH_ADDR_RAM
    lda CURSOR_ADDRESS_PTR+1
    sta SCRATCH_ADDR_RAM+1
    ldx #$00
    lda #CHAR_RAM_DEFAULT_VALUE
@loop:
    sta (SCRATCH_ADDR_RAM)
    inc SCRATCH_ADDR_RAM
    bne @no_rollover
    inc SCRATCH_ADDR_RAM+1
@no_rollover:
    inx
    cpx #LINE_NUM_CHARS
    beq @exit
    jmp @loop
@exit:
    rts

SET_SCROLL:
    lda #CRTC_START_L
    sta CRTC_ADDRESS
    lda VIDEO_SCROLL_POS
    sta CRTC_REGISTER

    lda #CRTC_START_H
    sta CRTC_ADDRESS
    lda VIDEO_SCROLL_POS+1
    sta CRTC_REGISTER
    rts

VIDEO_SCROLL_UP:
    lda VIDEO_SCROLL_POS
    clc
    adc #LINE_NUM_CHARS
    bcc @no_scroll_carry
    inc VIDEO_SCROLL_POS+1
@no_scroll_carry:
    sta VIDEO_SCROLL_POS
    rts

; A - register contains ascii character code to write to memory
; location pointed at by VIDEO_CURSOR_PTR
VIDEO_WRITE_CHAR:
    cmp #$0a ; is it a $0a character?
    bne @not_0a ; no, continue
    rts
@not_0a:
    cmp #$7f ; was it a backspace/delete?
    bne @backspace_not_pressed
    jmp @video_cursor_backspace
@backspace_not_pressed:
    PHA
    PHX
    ; set 0 to scratch data, 1 indicates clear current line
    ldx #$00
    stx SCRATCH_DATA_RAM
    ; check if it's the enter key
    cmp #$0D
    bne @enter_key_not_pressed
; here enter key was pressed...
    ldx #$01
    stx SCRATCH_DATA_RAM ; indicate to clear current line and check for scroll

    ; determine how many bytes to add to get to next line on display...
    lda #LINE_NUM_CHARS          ; load with 40 (or 40-1)
    SEC
    sbc CURSOR_X_POS    ; subtract cursor x position from 40, tells us how many to add to get to next line
    PHA
    ; A now contains how many bytes to add to get to next line
    JSR MOVE_CURSOR_POSITION
    PLA
    clc
    adc CURSOR_ADDRESS_PTR ; add value in low byte memory ptr to the amount we need to add
    bcc @no_low_255_rollover
    inc CURSOR_ADDRESS_PTR+1 ; we rolled over 255 on low byte
@no_low_255_rollover:
    sta CURSOR_ADDRESS_PTR
    lda #$00
    sta CURSOR_X_POS
    lda CURSOR_Y_POS
    cmp #MAX_LINE
    beq @dont_inc_y
    inc CURSOR_Y_POS
@dont_inc_y:
    jmp @check_at_max_video_ram
@enter_key_not_pressed:
    sta (CURSOR_ADDRESS_PTR)
    inc CURSOR_ADDRESS_PTR  ;increment cursor video memory position

    LDA #$01
    JSR MOVE_CURSOR_POSITION

    inc CURSOR_X_POS        ;increment our x char position tracker
    ldx CURSOR_X_POS        ; check if we are going to position 40 (next line so 0)
    cpx #LINE_NUM_CHARS                ; are we at char position 40?
    bne @check_256_vid_rollover ; no, skip ahead
    ldx #$00                    ; yes, reset it to 0
    stx CURSOR_X_POS
    lda CURSOR_Y_POS
    cmp #MAX_LINE
    beq @dont_inc_y2
    inc CURSOR_Y_POS
@dont_inc_y2:
    ldx #$01
    stx SCRATCH_DATA_RAM ; indicate to clear current line
@check_256_vid_rollover:
    ldx CURSOR_ADDRESS_PTR
    cpx #$00
    bne @check_at_max_video_ram
    inc CURSOR_ADDRESS_PTR+1
@check_at_max_video_ram:
    ldx CURSOR_ADDRESS_PTR+1
    cpx #>CHAR_RAM_END
    bcc @exit_video_write_char
    ldx CURSOR_ADDRESS_PTR
    cpx #<CHAR_RAM_END
    bcc @exit_video_write_char

    SEC
    LDA CURSOR_ADDRESS_PTR
    SBC #<CHAR_RAM_END
    STA CURSOR_ADDRESS_PTR
    LDA CURSOR_ADDRESS_PTR+1
    SBC #>CHAR_RAM_END
    CLC
    ADC #>CHAR_RAM
    STA CURSOR_ADDRESS_PTR+1

@exit_video_write_char:
    lda SCRATCH_DATA_RAM
    cmp #$00
    beq @exit
    jsr VIDEO_CLEAR_LINE
    ; do we need to adjust the vertical scrolling?
    lda CURSOR_Y_POS
    cmp #MAX_LINE
    bne @exit
    jsr VIDEO_SCROLL_UP
@exit:
    jsr SET_SCROLL
    PLX
    PLA
    rts

; back the cursor up 1 byte in the video ram
@video_cursor_backspace:
    phx
    ldx CURSOR_X_POS
    cpx #$00
    beq @video_cursor_backspace_exit
    dec CURSOR_ADDRESS_PTR
    dec CURSOR_X_POS
    ldx CURSOR_ADDRESS_PTR
    cpx #$ff
    bne @video_cursor_backspace_exit
    dec CURSOR_ADDRESS_PTR+1    
@video_cursor_backspace_exit:
    LDA #-1
    JSR CURSOR_BACKSPACE
    plx
    rts
