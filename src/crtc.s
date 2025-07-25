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
CRTC_SETTINGS: .byte $31, $28, $29, $06, $1f, $0d, $1e, $1f, $00, $0f, $00, $00, $00, $00, $00, $00

CRTC_ADDRESS = $8700
CRTC_REGISTER = $8701

INIT_CRTC:
    phx

    ldx #$00    ; crtc register address
    
@settings_loop:
    stx CRTC_ADDRESS     ; set crtc address
    lda CRTC_SETTINGS,x ; lda with setting #y from the CRTC_SETTINGS bytes
    sta CRTC_REGISTER   ; store in the crtc register pointed to by the address
    sta $0400,x
    inx
    cpx #$10            ; decimal 16
    bne @settings_loop

    plx
    
    rts