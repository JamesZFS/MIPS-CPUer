.set noat
.set noreorder
.globl __start
__start:
    nop
UTEST_1PTB:
    li $t0, 0x04000000
    nop
    nop
    nop
.LC0:
    addiu $t0, $t0, -1                // 滚动计数器
    ori $t1, $zero, 0
    ori $t2, $zero, 1
    ori $t3, $zero, 2
    bne $t0, $zero, .LC0
    nop
    li $at, 0xF
loop:
    j loop
    nop
