.org 0x0
.set noat
.set noreorder
.set nomacro
.globl _start
_start:
    ori $1,$0,0x100
    jr $1
    ori $1,$0,0x200
.org 0x40
    ori $1,$0,0x8000
    ori $1,$0,0x9000
    mfc0 $1,$14,0x0
    ori $1,$0,0x108
    mtc0 $1,$14,0x0
    eret
    nop

.org 0x100
    ori $1,$0,0x1000
    syscall
    ori $1,$0,0x9888
