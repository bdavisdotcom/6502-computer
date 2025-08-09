; configuration
CONFIG_2A := 1

CONFIG_SCRTCH_ORDER := 2

; zero page
ZP_START0 = $00
ZP_START1 = $06
ZP_START2 = $10
ZP_START3 = $62
ZP_START4 = $6D

; extra/override ZP variables
USR := GORESTART

; constants
SPACE_FOR_GOSUB := $3E
STACK_TOP := $FA
WIDTH := 40
WIDTH2 := 30
RAMSTART2 := $0400
