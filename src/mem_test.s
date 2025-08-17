.segment "BIOS"

RAM_TEST_MSG:   .byte "Running RAM self test...", $00
; RAM_TEST_WRITE: .byte "RAM writes...", $0d, $0a, $00
; RAM_TEST_READ:  .byte "RAM reads...", $0d, $0a, $00
RAM_TEST_FAIL:  .byte "FAIL!", $0d, $0a, $00
RAM_TEST_PASS:  .byte "SUCCESS!", $0d, $0a, $00
RAM_TEST_START = $0200
RAM_TEST_END_HIGH_BYTE = $80

MEM_TEST:

    ; RAM SELF TEST
    lda #<RAM_TEST_MSG
    sta $10
    lda #>RAM_TEST_MSG
    sta $11
    jsr PRINT_STR

    sei
.proc mem_test_write

    ; load A with start address of memory test
    ; start after stack page $0200
    lda #<RAM_TEST_START
    sta $10
    lda #>RAM_TEST_START
    sta $11

    ;fill RAM with 10101010 pattern
    lda #$aa
@memory_addr_loop:
    sta ($10)
    inc $10
    bne @memory_addr_loop
@inc_memory_page:
    inc $11
    lda $11
    cmp #RAM_TEST_END_HIGH_BYTE
    beq @memory_write_done
    lda #$aa
    jmp @memory_addr_loop

@memory_write_done:
    ; lda #<RAM_TEST_WRITE
    ; sta $10
    ; lda #>RAM_TEST_WRITE
    ; sta $11
    ; jsr PRINT_STR
.endproc

.proc mem_test_read

    ; load A with start address of memory test
    ; start after stack page $0200
    lda #<RAM_TEST_START
    sta $10
    lda #>RAM_TEST_START
    sta $11

    ;read memory locations and compare with 10101010
@memory_addr_loop:
    lda ($10)
    cmp #$aa
    bne @memory_test_fail
    inc $10
    bne @memory_addr_loop
@inc_memory_page:
    inc $11
    lda $11
    cmp #RAM_TEST_END_HIGH_BYTE
    beq @memory_test_done
    jmp @memory_addr_loop

@memory_test_fail:
    lda #<RAM_TEST_FAIL
    sta $10
    lda #>RAM_TEST_FAIL
    sta $11
    jsr PRINT_STR
    jmp @after_memtest

@memory_test_done:
    lda #<RAM_TEST_PASS
    sta $10
    lda #>RAM_TEST_PASS
    sta $11
    jsr PRINT_STR

@after_memtest:

.endproc

    cli
    rts