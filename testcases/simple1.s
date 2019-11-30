.set noat
.set noreorder
.globl __start
__start:
    nop
UTEST_4MDCT:
    li $t0, 0x1
    li $t0, 0x2
    li $t0, 0x3
    li $t0, 0x4
    li $t0, 0xAC
    nop
    nop
    nop
    nop
    nop
    nop
final:
    j  final
    nop
    nop
