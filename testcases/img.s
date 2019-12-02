.set noat
.set noreorder
.globl __start
__start:
    nop
begin:
    li  $t1, 0xA0000000 # on bram
    li  $t2, 0x80400000 # on extram
    li  $v0, 480000 # current pixel
    addu $t1, $t1, $v0 # target pixel addr
    addu $t2, $t2, $v0 # image source addr
draw:
    lb    $t0, 0($t2)  # load pixel from extram
    sb    $t0, 0($t1)  # draw pixel on screen
    addiu $v0, $v0, -1
    addiu $t1, $t1, -1
    addiu $t2, $t2, -1
    bnez  $v0, draw
    nop
    jr  $ra
    nop
