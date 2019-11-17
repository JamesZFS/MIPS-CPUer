.set noat
ori  $1, $0, 0x00000001
and  $2, $0, $1  # yields 0
ori  $3, $0, 3
movz $3, $1, $1  # yields 3
movz $3, $1, $2  # yields 1
