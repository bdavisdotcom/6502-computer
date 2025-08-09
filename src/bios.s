.setcpu "65C02"
.debuginfo
.zeropage

.org ZP_START0

INPUT_READ_PTR:       .res 1
INPUT_WRITE_PTR:      .res 1
KEYBOARD_FLAGS:       .res 1
CURSOR_ADDRESS_PTR:   .res 2
CURSOR_X_POS:         .res 1
CURSOR_Y_POS:         .res 1

.segment "INPUT_BUFFER"

INPUT_BUFFER:   .res $100

.segment "RAM"
.segment "IO"
.segment "BIOS"

WELCOME_MSG:    .byte "Welcome to Brad's 6502", $0d, $0a, $00
INIT_CRTC_MSG:    .byte "Initializing CRTC", $0d, $0a, $00
RUNNING_WOZMON:  .byte "Running Wozmon...", $0d, $0a, $00
ACIA_DATA       = $8000
ACIA_STATUS     = $8001
ACIA_CMD        = $8002
ACIA_CTRL       = $8003
PORTB           = $8100
PORTA           = $8101
DDRB            = $8102
DDRA            = $8103
PCR             = $810C
IFR             = $810D
IER             = $810E
  
RESET:
    CLD                     ; Clear decimal arithmetic mode.
    CLI                     ; enable interrupts

    ; initialize crtc / display
    jsr INIT_CRTC

    JSR INIT_BUFFER     ; initialize rs-232 serial input buffer

    ; initialize 65c22 VIA chip
    lda #$01            ; CA1 rising edge interrupt mode
    sta PCR
    lda #$82            ; enable CA1 interrupts
    sta IER

    lda #$00
    sta DDRA                ; set PORTA pins to INPUT
    sta KEYBOARD_FLAGS      ; clear all keyboard flags to 0

    lda #$ff        
    sta DDRB                ; Set all pins on port B to OUTPUT

    ; initialize rs-232 serial port
    LDA #$1F            ; 8-N-1, 19200 bps
    STA ACIA_CTRL
    LDY #$89            ; No parity, no echo, rx interrupts.
    STY ACIA_CMD

    lda #<WELCOME_MSG
    sta $10
    lda #>WELCOME_MSG
    sta $11
    jsr PRINT_STR

    ; perform RAM test
    jsr MEM_TEST

    lda #<INIT_CRTC_MSG
    sta $10
    lda #>INIT_CRTC_MSG
    sta $11
    jsr PRINT_STR

    lda #<RUNNING_WOZMON
    sta $10
    lda #>RUNNING_WOZMON
    sta $11
    jsr PRINT_STR

    ; start wozmon
    JMP RESET_WOZMON    ; start running WOZMON!

LOAD:
    rts

SAVE:
    rts

; asciiz string starting at address stored in $10, $11
; string must be 255 bytes or less
PRINT_STR:
    phy
    ldy #$00
@print_str_loop:
    lda ($10),y
    beq @print_str_done ; if byte is 00, we're done
    jsr CHROUT
    iny
    jmp @print_str_loop
@print_str_done:
    ply
    rts

; Input a character from the serial interface.
; On return, carry flag indicates whether a key was pressed
; If a key was pressed, the key value will be in the A register
;
; Modifies: flags, A
MONRDKEY:
CHRIN:
    phx
    jsr BUFFER_SIZE
    beq @no_keypressed
    jsr READ_BUFFER
    jsr CHROUT                  ; echo
    pha
    jsr BUFFER_SIZE
    cmp #$B0
    bcs @mostly_full
    lda #$7f
    and PORTB
    sta PORTB

@mostly_full:
    pla
    plx
    sec
    rts

@no_keypressed:
    plx
    clc
    rts


; Output a character (from the A register) to the serial interface.
;
; Modifies: flags
MONCOUT:
CHROUT:
    pha
    jsr VIDEO_WRITE_CHAR
    sta ACIA_DATA
    lda #$FF
@txdelay:       
    dec
    bne @txdelay
    pla
    rts

; Initialize the circular input buffer
; Modifies: flags, A
INIT_BUFFER:
    lda INPUT_READ_PTR
    sta INPUT_WRITE_PTR
    rts

; Write a character (from the A register) to the circular input buffer
; Modifies: flags, X
WRITE_BUFFER:
    ldx INPUT_WRITE_PTR
    sta INPUT_BUFFER,x
    inc INPUT_WRITE_PTR
    rts

; Read a character from the circular input buffer and put it in the A register
; Modifies: flags, A, X
READ_BUFFER:
    ldx INPUT_READ_PTR
    lda INPUT_BUFFER,x
    inc INPUT_READ_PTR
    rts

; Return (in A) the number of unread bytes in the circular input buffer
; Modifies: flags, A
BUFFER_SIZE:
    lda INPUT_WRITE_PTR
    sec
    sbc INPUT_READ_PTR
    rts

; Interrupt request handler
IRQ_HANDLER:
    pha
    phx

    lda ACIA_STATUS
    rol A               ; shift A bit 7 into carry
    bcc @via_interrupt  ; bit 7 was 0, so not an ACIA interrupt
    
    ; it is an ACIA interrupt
    lda ACIA_DATA
    jsr WRITE_BUFFER
    jsr BUFFER_SIZE
    cmp #$F0
    bcc @exit_irq
    lda #$80
    ora PORTB
    sta PORTB
    jmp @exit_irq

@via_interrupt:
    lda IFR
    and #%00000010
    beq @exit_irq

    JSR KEYBOARD_INPUT_HANDLER

@exit_irq:
    plx
    pla
    rti

.include "mem_test.s"
.include "crtc.s"
.include "keyboard.s"
.include "wozmon.s"

.segment "RESETVEC"
    .word $0F00           ; NMI vector
    .word RESET           ; RESET vector
    .word IRQ_HANDLER     ; IRQ vector
