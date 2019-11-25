.set noreorder
.globl __start
.text
__start:
    nop
begin:
    li  $2, 0x32
    li  $4, 0xbb
    lb  $3, a($0) # mem read,  $3 == 0xffffffaa
    sb  $2, a+4($0) # mem store to 1st byte of next word of a
    sb  $4, a+5($0) # mem store to 2nd byte of next word of a
    nop
    lb  $3, a+4($0) # mem read,  $3 == 0x00000032
    lb  $3, a+5($0) # mem read,  $3 == 0xffffffbb
    nop
    j  end
    nop

a: .word  0xaaaa
.space    4

end:
    nop