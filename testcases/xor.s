.set noat
or  $1, $0, $0
ori $1, $0, 0x00000001
nop
ori $2, $1, 0x00001000  # conflict 2, yields 0x00001001
ori $3, $1, 0x00000100  # conflict 3, yields 0x00000101
and  $4, $2, $3         # conflict 1, 2; should yield 0x00000001
andi $5, $1, 0x0000ffff # should yield 0x00000001
xori $5, $1, 0x00000110 # yields 0x00000111
xor  $6, $5, $2         # conflict 1; yields 0x00001110
