.set noreorder
.set noat
.globl __start
.text
__start:
  ori $t0, $zero, 0x1 # t0 = 1
  ori $t1, $zero, 0x1 # t1 = 1
loop: addu $t2, $t0, $t1 # t2 = t0+t1
  ori $t0, $t1, 0x0 # t0 = t1
  ori $t1, $t2, 0x0 # t1 = t2
  j loop
  ori $zero, $zero, 0 # noop
