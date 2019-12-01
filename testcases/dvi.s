.set noat
.set noreorder
.globl __start
__start:
    nop
begin:
    li  $t0, 0xDF  # current color
    li  $t2, 1000  # alter times
alter_color:
    li  $t1, 0xB0000000
    li  $v0, 0 # current pixel
    li  $v1, 240000 # upper pixel
    addu $t1, $t1, $v0 # compute current pixel addr
    addiu $t0, $t0, 1 # alter color
draw:
    sb    $t0, 0($t1)
    addiu $v0, $v0, 1
    addiu $t1, $t1, 1
    bne   $v0, $v1, draw
    nop
    addiu $t2, $t2, -1
    bnez  $t2, alter_color
    nop
    jr  $ra
    nop

