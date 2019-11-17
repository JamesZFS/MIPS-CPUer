.set noat
ori   $1, $0, 45
ori   $2, $0, 19
addu  $3, $1, $2  # yields 0x00000040
addiu $3, $3, 0xfffa # yields 0x0001003a
