.org 0x0
.set noat
.set noreorder
.set nomacro
.globl _start
_start:
    ori $3,$0,0x8000 # (1) start
    beq $3,$3,s3 # (2) jump if equals, $3 == $3 so jump
    ori $1,$0,0x0006 # (3) into delay slot
    ori $1,$0,0x1111
    ori $1,$0,0x1100

s3: # (4) landed here from (2)
    ori $1,$0,0x0005 # (5) run normally 
    bgtz $1, s4 # (6) jump if greater than 0, $1 > 0 so jump
    ori $1,$0,0x1111 # (7) into delay slot
    ori $1,$0,0x1100

s4: # (8) landed here from (6)
    ori $1,$0,0x1101 # (9) run normally
    ori $1,$0,0x1111 # (10) run normally
    bne $1,$0, s5 # (11) jump if not equal, $1 != $0 so jump
    ori $1,$0,0x6666 # (12) into delay slot

s5: # (13) landed here from (11)
    ori $1,$0,0x7777 # (14) run normally
    ori $2,$0,0x8888 # (15) run normally
    beq $3,$2,s3 # (16) jump if equal, $3 != $2 so no jump
    ori $1,$0,0x9000 # (17) run normally
    ori $2,$0,0x9000 # (18) run normally
    beq $1,$2,s6 # (19) jump if equal, $1 == $2 so jump

s6: # (20) landed from (19)
    ori $1,$0,0x9999 # (21) finish

