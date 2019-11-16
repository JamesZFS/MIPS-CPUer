.set noat
ori $1, $0, 1
sll $1, $1, 3  # conflict 1; yields 0x00000008
srl $1, $1, 2  # conflict 2; yields 0x00000002
ori $2, $1, 0x130  # conflict 1; yields 0x00000132
nop
sll $2, $2, 24  # yields 0x32000000
srl $3, $2, 28  # yields 0x00000003
