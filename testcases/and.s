.set noat
# addu $1, $0, $2
# nop
# j  a				# j  a
# nop
# nop
# nop
# nop
# nop
# a:
# nop
# nop
# nop
# sw		$1, 0($2)	
# nop
# nop
# ori  $1, $0, 0x1
# nop
# nop
lui  $1,  0x1
or   $1,  $2, $3
clz  $1,  $2
andi $t0, $0, 0xAC
# ori  $t0, $0, 0xAC
nop
nop
loop:
nop
nop
nop
nop
nop
nop
nop
nop
nop
j loop
nop
# ori $1, $0, 0x00000001
# nop
# ori $2, $1, 0x00001000  # conflict 2
# ori $3, $1, 0x00000100  # conflict 3
# and  $4, $2, $3  # conflict 1, 2; should yield 0x00000001
# andi $5, $1, 0x0000ffff # should yield 0x00000001
