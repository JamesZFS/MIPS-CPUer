.org 0x0
.globl _start
_start:
    ori $2,$0,0xffff
    sll $2,$2,16
    ori $2,$2,0xfff1
    ori $3,$0,0x11

    div $zero,$2,$3
    divu $zero,$2,$3
    div $zero,$3,$2
    ori $5,$0,0x20
    ori $6,$0,0x30