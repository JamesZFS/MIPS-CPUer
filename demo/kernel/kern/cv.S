#ifdef MACH_FPGA
#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>
#include <shell.h>

    .set noreorder
    .set noat
    .p2align 2
    .section .text.cv
    .global CV_show_img
    .global CV_draw_pt
    .global CV_draw_square

/* diplay an image to blockram
   a0: start address of the image(size 480000 bytes)
*/ 
CV_show_img:
    li   t1, 0xA0000000 # on bram
    move t2, a0 # on extram
    li   t3, 480000 # current pixel
    addu t1, t1, t3 # target pixel addr
    addu t2, t2, t3 # image source addr
.show_img_draw:
    lb    t0, 0(t2)  # load pixel from extram
    sb    t0, 0(t1)  # draw pixel on screen
    addiu t3, t3, -1
    addiu t1, t1, -1
    addiu t2, t2, -1
    bnez  t3, .show_img_draw
    nop
    jr  ra
    nop


CV_draw_pt:
    /*
    input:
        a0: physical coordinate x, in [0, 800)
        a1: physical coordinate y, in [0, 600)
        a2: color in byte(R3:G3:B2)
    output:
        blockram updated
    */
    # compute pixel address
    li  t0, 800
    mul a1, a1, t0
    addu a0, a0, a1 # x + 800 *y
    # draw
    li t1, 0xA0000000 # on bram
    addu a0, a0, t1
    jr ra
      sb a2, 0(a0) # store to bram


CV_draw_square:
    /*
    input:
        a0: physical coordinate center x, in [0, 800)
        a1: physical coordinate center y, in [0, 600)
        a2: half width(also height) <= 300
        a3: color in byte(R3:G3:B2)
    output:
        blockram updated
    */
    # compute pixel address
    addiu sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    li  s5, 800
    subu s0, a0, a2 # lower x
    addu s1, a0, a2 # upper x
    subu s2, a1, a2 # lower y
    addu s3, a1, a2 # upper y

    #define i a2
    #define j t5
    #define addr a1
    lui s4, 0xA000 # on bram

    move i, s2
    loop_i:
        move j, s0
        mul addr, i, s5
        addu addr, addr, s0
        addu addr, s4, addr # current addr = 0xA0000000 + i * 800 + j
        loop_j:
            sb a3, 0(addr) # draw
            addiu addr, addr, 1
            addiu j, j, 1
            bne j, s1, loop_j
              nop

        addiu i, i, 1
        bne i, s3, loop_i
          nop
    
    #undef i
    #undef j
    #undef addr

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addiu sp, sp, 28
    jr ra
        nop


UTEST_drawpt:
    addiu sp, sp, -4
    sw ra, 0(sp)
    
    li a0, 400
    li a1, 300
    li a2, 0xE3 # 0b11100011
    jal CV_draw_pt
      nop
    
    li a0, 401
    li a1, 300
    li a2, 0xE3 # 0b11100011
    jal CV_draw_pt
      nop
    
    li a0, 400
    li a1, 301
    li a2, 0xE3 # 0b11100011
    jal CV_draw_pt
      nop

    li a0, 401
    li a1, 301
    li a2, 0xE3 # 0b11100011
    jal CV_draw_pt
      nop
    
    lw ra, 0(sp)
    addiu sp, sp, 4
    jr ra
      nop


UTEST_drawsqr:
    li a0, 400
    li a1, 300
    li a2, 100
    li a3, 0xE3
    j CV_draw_square
        nop

#endif // MACH_FPGA
