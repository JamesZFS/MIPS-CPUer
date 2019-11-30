.set noreorder
.globl __start
.text
__start:
    nop
begin:
    li   $s0, 0x20  # i = 0x20 
loop:
    addiu $s0, $s0, 1 # i++
    li   $v0, 30
    move $a0, $s0
    syscall     # putchar
    addiu $s1, $s0, -0x7f
    bnez  $s1, loop
    nop
end:
    jr  $ra
    nop
