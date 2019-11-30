.org 0x0
.set noat
.globl _start
_start:
    lui $1,0x0000
    lui $2,0xffff
    lui $3,0x0505
    lui $4,0x0000

    movz $4,$2,$1

    mthi $0
    mthi $2
     
    mthi $3
    mfhi $4 # hi forwarding test

    mtlo $3
    mflo $6 # lo forwarding test

    mtlo $2
    mtlo $1

    mflo $4