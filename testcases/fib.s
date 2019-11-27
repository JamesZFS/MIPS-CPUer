.set noat
.globl __start
.text
__start:
  nop

init:
  li $5, 0xbfd003f0
  li $7, 0
  ori $1, $zero, 0 # a0 = 1
  ori $2, $zero, 1 # a1 = 1

loop:
  addu $3, $1, $2 # an+1 = an + an-1
  # jal pause
  ori $1, $2, 0
  # jal print
  ori $2, $3, 0
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

  li  $6, 0x80000000 # baseram
  addiu $6, $6, a
  addu $6, $6, $7
  sw  $1, 0($6) # store $1 to baseram
  li  $6, 0x80400000 # extram
  addu $6, $6, $7
  sw  $1, 0($6) # store $1 to extram
  addiu $7, 4  # mem counter += 4 bytes

  jr  $ra
  nop

a: # base ram storage
  .space 100
