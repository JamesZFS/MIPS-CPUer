#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>

    .set noreorder
    .set noat
    .p2align 2
    .text
    .global SHOW_IMG

/* diplay an image to blockram
   a0: start address of the image(size 480000 bytes)
*/ 
SHOW_IMG:
.begin:
    li   t1, 0xA0000000 # on bram
    move t2, a0 # on extram
    li   t3, 480000 # current pixel
    addu t1, t1, t3 # target pixel addr
    addu t2, t2, t3 # image source addr
.draw:
    lb    t0, 0(t2)  # load pixel from extram
    sb    t0, 0(t1)  # draw pixel on screen
    addiu t3, t3, -1
    addiu t1, t1, -1
    addiu t2, t2, -1
    bnez  t3, .draw
    nop
    jr  ra
    nop

