.set noreorder
.globl __start
.text
__start:
    nop
begin:
    li  $t0, 0x32
    li  $4, 0xbb
    lb  $t1, a($0) # mem read,  $3 == 0xffffffaa
    sb  $t0, a+4($0) # mem store to 1st byte of next word of a
    sb  $4, a+5($0) # mem store to 2nd byte of next word of a
    nop
    lb  $t1, a+4($0) # mem read,  $3 == 0x00000032
    lb  $t1, a+5($0) # mem read,  $3 == 0xffffffbb
    nop
    j  end
    nop

a: .word  0xaaaa
.space    4

end:
    nop
    j   end
    nop
    nop
