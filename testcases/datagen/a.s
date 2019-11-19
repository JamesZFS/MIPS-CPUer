.set noat
.globl _start
_start:
    ori  $1, $0, 0x00000001
    clz  $2, $1  # yields 31 == 0x0000001f
    ori  $1, $0, 0x00001001
    clz  $2, $1  # yields 19 == 0x00000013
    clz  $2, $0  # yields 32 == 0x00000020
    lui  $1, 0x1234  # yields 0x12340000
    ori  $2, $1, 0xffff # yields 0x1234ffff
    lui  $2, 0x00aa  # yields 0x00aa0000
    clz  $3, $2      # yields 8
