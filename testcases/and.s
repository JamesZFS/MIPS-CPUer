.set noat
or  $1, $0, $0
ori $1, $0, 0x00000001
nop
ori $2, $1, 0x00001000  # conflict 2
ori $3, $1, 0x00000100  # conflict 3
and  $4, $2, $3  # conflict 1, 2; should yield 0x00000001
andi $5, $1, 0x0000ffff # should yield 0x00000001
