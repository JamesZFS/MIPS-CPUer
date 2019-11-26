.set noat
.globl __start
.text
__start:
  nop

init:
  li $5,0xbfd003f0
  ori $1, $zero, 0 # a0 = 1
  ori $2, $zero, 1 # a1 = 1

loop:
  addu $3, $1, $2 # an+1 = an + an-1
  ori $1, $2, 0
  ori $2, $3, 0
  jal pause
  nop
  jal print
  nop
  j loop
  nop

pause:
  lb   $6, 0xc($5) # uart status
  andi $6, $6, 2  # data ready?
  beq  $6, $0, pause # wait until response
  nop
  lb  $0, 0x8($5) # read a char
  jr  $ra
  nop

print:
  lb   $6, 0xc($5)  # stat
  andi $6, $6, 1    # data sent?
  beq  $6, $0, print # wait until ready
  nop
  addiu $6, $1, '0' # convert from hex to char, though I did not implement a hex to dec program...
  sb  $6, 0x8($5) # send $1 to uart (print $1)
  jr  $ra
  nop
