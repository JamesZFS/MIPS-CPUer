.set noreorder
.globl __start
.text
__start:
    nop
begin:
    li  $2, 2
    lw  $3, a($0) # mem read,  $3 == 0xaaaa
    sw  $2, a+4($0) # mem store to next word of a
    nop
    lw  $3, a+4($0) # mem read,  $3 == 0x2
    nop
    j  end
    nop

a: .word  0xaaaa
.space    4

end:
    nop
    j  end
    nop
 