.set noat
ori   $1, $0, 45
ori   $2, $0, 19
addu  $3, $1, $2  # yields 0x00000040, stall
addiu $3, $3, 0xfffa # yields 0x0001003a, stall
ori   $3, $0, 1
ori   $3, $0, 2
ori   $3, $0, 3
ori   $2, $0, 1
addu  $3, $3, $2  # yields 4, stall
ori   $3, $3, 0x1 # yields 5
and   $3, $2, $3  # yileds 1
