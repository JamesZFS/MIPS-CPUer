.set noat
.set noreorder
.globl __start
__start:
    nop
UTEST_4MDCT:
    li $sp, 0x804F0000
    # li $sp, 0x804f0000
    # li $sp, 0x80100000
    li $t0, 0x10
    addiu $sp, $sp, -4
.LC3:
    sw $t0, 0($sp)
    lw $t1, 0($sp)
    addiu $t1, $t1, -1
    sw $t1, 0($sp)
    lw $t0, 0($sp)
    bne $t0, $zero, .LC3
    nop

    addiu $sp, $sp, 4
    li $t0, 0xAC
final:
    j  final
    nop

# data: .space 16