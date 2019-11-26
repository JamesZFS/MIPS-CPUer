.set noreorder
.globl __start
.text
.equ extaddr, 0x80400000
__start:
    nop
begin:
    lb  $2, a($0)  # $2 == 0xFFFFFF8D
    lbu $2, a($0)  # $2 == 0x8d
    lb  $2, a+1($0)  # $2 == 0xc
    lbu $2, a+1($0)  # $2 == 0xc
    lb  $2, a+2($0)  # $2 == 0xb
    ori $3, $2, 0    # $3 == 0xb
    lb  $2, a+3($0)  # $2 == 0xa
    andi $3, $2, 0x7 # $3 == 0x2
    nop
    lb  $2, extaddr($0) # 0xFFFFFF81
    lbu $2, extaddr($0) # 0x81
    lb  $2, extaddr+1($0) # 0x2
    ori $3, $2, 0   # 0x1003
    lb  $2, extaddr+2($0) # 0x3
    lb  $2, extaddr+3($0) # 0x4
    j   end
    nop

a: 
.byte 0x8d
.byte 0xc
.byte 0xb 
.byte 0xa
.space  4

end: 
    nop
