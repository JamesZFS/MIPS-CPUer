.set noreorder
.globl __start
.text
__start:
    nop
begin:
    ori $1, $0, 0x00000001
    ori $2, $1, 0x00001000  # conflict 1
    ori $3, $1, 0x00000100  # conflict 2
    ori $4, $1, 0x00000010  # conflict 3
    ori $5, $1, 0x00000010  # no conflict
    ori $6, $0, 0x0000006a
    ori $7, $5, 0x00000100  # conflict 2
    j end
    nop

a: 
.byte 0x8d
.byte 0xc
.byte 0xb 
.byte 0xa
.space  4

end: 
    nop
