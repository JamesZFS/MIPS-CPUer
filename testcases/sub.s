.org 0x0
.set noat
.globl _start
_start:
    ori $1,$0,0x8765
    ori $2,$0,0x1234
    subu $3,$1,$2
    sub $4,$1,$2
    subu $5,$2,$1
    sub $6,$2,$1
