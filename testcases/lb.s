.set noreorder
.globl __start
.text
__start:
    nop
begin:
    lb  $2, a($0)  # $2 == 0xd
    lb  $2, a+1($0)  # $2 == 0xc
    lb  $2, a+2($0)  # $2 == 0xb
    lb  $2, a+3($0)  # $2 == 0xa
    j   end
    nop

a: .word  0x0a0b0c0d
.space    4 

end:
    nop
