; keyboard is connected throught the VIA PORTA
;
; 384 bytes for keyboard mapping normal, shifted, caps-locked

.feature string_escapes +
KEYBOARD_MAP:
  .byte "????????????? `?"            ; 00-0F
  .byte "?????q1???zsaw2?"            ; 10-1F
  .byte "?cxde43?? vftr5?"            ; 20-2F
  .byte "?nbhgy6???mju78?"            ; 30-3F
  .byte "?,kio09??./l;p-?"            ; 40-4F
  .byte "??'?[=?????]?\\??"            ; 50-5F
  .byte "?????????1?47???"            ; 60-6F
  .byte "0.2568???+3-*9??"            ; 70-7F

KEYBOARD_MAP_SHIFTED:
  .byte "????????????? ~?"            ; 00-0F
  .byte "?????Q!???ZSAW@?"            ; 10-1F
  .byte "?CXDE#$?? VFTR%?"            ; 20-2F
  .byte "?NBHGY^???MJU&*?"            ; 30-3F
  .byte "?<KIO)(??>?L:P_?"            ; 40-4F
  .byte "??\"?{+?????}?|??"          ; 50-5F
  .byte "?????????1?47???"          ; 60-6F
  .byte "0.2568???+3-*9??"          ; 70-7F

KEYBOARD_MAP_CAPS_LOCK:
  .byte "????????????? `?"            ; 00-0F
  .byte "?????A1???ZSAW2?"            ; 10-1F
  .byte "?CXDE43?? VFTR5?"            ; 20-2F
  .byte "?NBHGY6???MJU78?"            ; 30-3F
  .byte "?,KIO09??./L;P-?"            ; 40-4F
  .byte "??'?[=?????]?\\??"            ; 50-5F
  .byte "?????????1?47???"            ; 60-6F
  .byte "0.2568???+3-*9??"            ; 70-7F
.feature string_escapes -

RELEASE     = %00000001
SHIFT       = %00000010
CAPS_LOCK   = %00000100

; modifies A, X
; leaves key in A
KEYBOARD_INPUT_HANDLER:             ; called from INTB handler
    pha
    phx

    lda KEYBOARD_FLAGS
    and #RELEASE                    ; check if we're releasing a key
    beq @read_key_from_portA        ; no? then just read the key and process it

    ; yes, releasing a key...
    lda KEYBOARD_FLAGS          
    eor #RELEASE                    ; toggle the release bit
    sta KEYBOARD_FLAGS              ; store the new value
    lda PORTA                       ; read to clear interrupt clear
    cmp #$12                        ; left shift
    beq @shift_up
    cmp #$59                        ; right shift
    beq @shift_up
    jmp @exit

@read_key_from_portA:
    lda PORTA
    cmp #$f0
    beq @key_release
    cmp #$12                        ; left shift
    beq @shift_down
    cmp #$59                        ; right shift
    beq @shift_down
    cmp #$5A
    beq @enter_key
    cmp #$66
    beq @backspace_key
    cmp #$58
    beq @caps_lock_pressed

    ; unmapped keys just convert to "?"
    ; key codes > $7f (80 and up) unmapped
    cmp #$80
    bcc @valid_key_code
    lda #$3f                        ; this was unmapped, so "?"
    jmp @push_key_to_buffer

@valid_key_code:
    tax
    lda KEYBOARD_FLAGS
    and #SHIFT
    bne @shifted_key
    lda KEYBOARD_FLAGS
    and #CAPS_LOCK
    bne @caps_lock_key

    lda KEYBOARD_MAP, x
    jmp @push_key_to_buffer

@caps_lock_pressed:
    lda KEYBOARD_FLAGS
    eor #CAPS_LOCK                  ; flip caps lock bit
    sta KEYBOARD_FLAGS              ; store new flags register
    jmp @exit

@backspace_key:
    lda #$08
    jmp @push_key_to_buffer

@enter_key:
    lda #$0D
    jmp @push_key_to_buffer

@shifted_key:
    lda KEYBOARD_MAP_SHIFTED, x
    jmp @push_key_to_buffer

@caps_lock_key:
    lda KEYBOARD_MAP_CAPS_LOCK, x
    ; falls thru to @push_key_to_buffer!!!

@push_key_to_buffer:
    jsr     WRITE_BUFFER
    jmp     @exit

@shift_up:
    lda     KEYBOARD_FLAGS
    eor     #SHIFT
    sta     KEYBOARD_FLAGS
    jmp     @exit
    
@shift_down:
    lda     KEYBOARD_FLAGS
    ora     #SHIFT
    sta     KEYBOARD_FLAGS
    jmp     @exit

@key_release:
    lda     KEYBOARD_FLAGS
    ora     #RELEASE
    sta     KEYBOARD_FLAGS

@exit:
    plx
    pla
    rts
