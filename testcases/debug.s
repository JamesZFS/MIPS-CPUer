.set noat
.globl __start
.text
__start:
  or $1, $1, $0
  nop
  j init
  nop

init:
  li $a0, 0xbfd003f0
  li $t0, 4
  li $sp, 16

.LC1:
  addiu $t0, $t0, -1                // 滚动计数器
  addiu $sp, $sp, -4                // 移动栈指针
  sw $zero, 0($sp)                  // 初始化栈空间
  bne $t0, $zero, .LC1              // 初始化循环
  nop

print:
  lb   $v0, 0xc($a0)  # stat
  andi $v0, $v0, 1    # data sent?
  beq  $v0, $0, print # wait until ready
  nop
  j  finish
  nop

data:
  .space 8
  .word 0x11111111
  .word 0x22222222
  .word 0x33333333
last:
  .word 0x44444444
  .space 8

finish:
  ori $v0, $zero, '#'
  sb  $v0, 0x8($a0) # send to uart
  jr  $ra
  nop


