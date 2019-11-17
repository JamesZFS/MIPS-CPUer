.set noat
lui  $1, 0x1234  # yields 0x12340000
ori  $2, $1, 0xffff # yields 0x1234ffff
lui  $2, 0x00aa  # yields 0x00aa0000
clz  $3, $2      # yields 8
