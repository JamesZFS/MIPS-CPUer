.org 0x0
.set noat
.set noreorder
.set nomacro
.globl _start
_start:
    ori $1,$0,0xf
    mtc0 $1,$11,0x0

    lui $1,0x1000
    ori $1, $1, 0x401
    mtc0 $1,$12,0x0
    mfc0 $2,$12,0x0
    move $3, $2

    mtc0 $2, $10, 0x0
    mfc0 $5, $10, 0x0
    move $4, $5
    
    nop
    nop
    nop
