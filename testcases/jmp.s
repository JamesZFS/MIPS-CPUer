.org 0x0
.set noat
.set noreorder
.set nomacro
.globl _start
_start:
    ori $1,$0,0x0001 # (1) start
    j 0x20  # (2) jump to 0x20 unconditional
    ori $1,$0,0x0002 # (3) into delay slot
    ori $1,$0,0x1111
    ori $1,$0,0x1100

    .org 0x20 # (4) landed here from (2)
    ori $1,$0,0x0003 # (5) run normally
    jal 0x40 # (6) give register 31 value of pc+8 which is 2c
    ori $4,$0,0x0005 # (7) into delay slot


    ori $1,$0,0x0005 # (12) landed here from (10)
    ori $1,$0,0x0006 # (13) run normally
    j 0x60 # (14) jump to 0x60 unconditionally
    nop # (15) into delay slot

    .org 0x40 # (8) landed here from (5)
    ori $1,$0,0x0006 # (9) run normally
    jr $31 # (10) look for the value of $31 and jump, so jump to 2c

    ori $1,$0,0x0009 # (11) into delay slot 
    ori $1,$0,0x000a
    j 0x80

    .org 0x60 # (16) landed here from (14)
    ori $1,$0,0x0007 # (17) run normally
    ori $2,$0,0x80 # (18) run normally 
    jr $2 # (19) look fo the value of $2 and jump, so 0x80
    ori $1,$0,0x0008 # (20) into delay slot
    ori $1,$0,0x1111
    ori $1,$0,0x1100

    .org 0x80 # (21) landed here from (19)
    nop # (22) finish

