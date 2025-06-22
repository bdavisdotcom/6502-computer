.setcpu "65C02"
.debuginfo

.zeropage
                .org ZP_START0
READ_PTR:       .res 1
WRITE_PTR:      .res 1

.segment "INPUT_BUFFER"
INPUT_BUFFER:   .res $100

.segment "RAM"
.segment "IO"
.segment "BIOS"

ACIA_DATA       = $8000
ACIA_STATUS     = $8001
ACIA_CMD        = $8002
ACIA_CTRL       = $8003
PORTA           = $8401
DDRA            = $8403
PORTB           = $8400
DDRB            = $8402
PCR             = $840C
IFR             = $840D
IER             = $840E

RESET:
                CLD                     ; Clear decimal arithmetic mode.
                JSR     INIT_BUFFER

; INIT CTS pin for rs-232
                lda #$ff
                sta DDRA        ; set PORTA pins to output
                lda #$00        ; set PORTA pins to 0
                sta PORTA

                lda #$ff ; Set all pins on port B to output
                sta DDRB
; done init cts

                CLI
                LDA     #$1F            ; 8-N-1, 19200 bps
                STA     ACIA_CTRL
                LDY     #$89            ; No parity, no echo, rx interrupts.
                STY     ACIA_CMD
                JMP     RESET_WOZMON

LOAD:
                rts

SAVE:
                rts


; Input a character from the serial interface.
; On return, carry flag indicates whether a key was pressed
; If a key was pressed, the key value will be in the A register
;
; Modifies: flags, A
MONRDKEY:
CHRIN:
                phx
                jsr     BUFFER_SIZE
                beq     @no_keypressed
                jsr     READ_BUFFER
                jsr     CHROUT                  ; echo
                pha
                jsr     BUFFER_SIZE
                cmp     #$B0
                bcs     @mostly_full
                ; lda     #$fe
                ; and     PORTA
                ; sta     PORTA
                lda     #$7f
                and     PORTB
                sta     PORTB
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
                sta     ACIA_DATA
                lda     #$FF
@txdelay:       dec
                bne     @txdelay
                pla
                rts

; Initialize the circular input buffer
; Modifies: flags, A
INIT_BUFFER:
                lda READ_PTR
                sta WRITE_PTR
                rts

; Write a character (from the A register) to the circular input buffer
; Modifies: flags, X
WRITE_BUFFER:
                ldx WRITE_PTR
                sta INPUT_BUFFER,x
                inc WRITE_PTR
                rts

; Read a character from the circular input buffer and put it in the A register
; Modifies: flags, A, X
READ_BUFFER:
                ldx READ_PTR
                lda INPUT_BUFFER,x
                inc READ_PTR
                rts

; Return (in A) the number of unread bytes in the circular input buffer
; Modifies: flags, A
BUFFER_SIZE:
                lda WRITE_PTR
                sec
                sbc READ_PTR
                rts


; Interrupt request handler
IRQ_HANDLER:
                pha
                phx
                lda     ACIA_STATUS
                ; For now, assume the only source of interrupts is incoming data
                lda     ACIA_DATA
                jsr     WRITE_BUFFER
                jsr     BUFFER_SIZE
                cmp     #$F0
                bcc     @not_full
                ; lda     #$01
                ; ora     PORTA
                ; sta     PORTA
                lda     #$80
                ora     PORTB
                sta     PORTB
@not_full:
                plx
                pla
                rti

.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00           ; NMI vector
                .word   RESET           ; RESET vector
                .word   IRQ_HANDLER     ; IRQ vector

