# .org 0x0
# .set noat
.globl _start
_start:
li   $t0, 0x003e4ae5
li   $t1, 0xffb43669
mult $t0, $t1
mfhi $t2
mflo $t3
srl  $t4, $t3, 16
sll  $v0, $t2, 16
or   $t4, $t4, $v0
jr   $ra
nop
