.set noat
ori  $1, $0, 0x00000001
clz  $2, $1  # yields 31 == 0x0000001f
ori  $1, $0, 0x00001001
clz  $2, $1  # yields 19 == 0x00000013
clz  $2, $0  # yields 32 == 0x00000020
