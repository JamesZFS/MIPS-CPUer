.set noat
.globl __start
.text
__start:
  ori $1, $zero, 0 # a0 = 1
  ori $2, $zero, 1 # a1 = 1
  ori $4, $0, 0 # counter
  ori $5, $0, 10
loop:
  addu $3, $1, $2 # an+1 = an + an-1
  ori $1, $2, 0
  ori $2, $3, 0
  addiu $4, $4, 1
  beq $4, $5, exit	# if $4 == $5 then exit
  nop
  j loop
  nop

exit:
  ori $1, $0, 0 # noop
