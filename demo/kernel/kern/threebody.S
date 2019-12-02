#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>
#include <demo.h>

    .set noreorder
    .set noat
    .p2align 2
    .text


TB_dist:
    /* compute distance between two fpn vector2
    input:
      a0: fpn a.x
      a1: fpn a.y
      a2: fpn b.x
      a3: fpn b.y
    output:
      v0: fpn dist
    */
    addiu sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    sub  t0, a0, a2
    sub  t1, a1, a3
    move a0, t0
    jal fpn_mul
      move a1, t0
    move s0, v0  # s0 = dx*dx
    move a0, t1 # notice t1 isn't changed by fpn_mul
    jal fpn_mul
      move a1, t1 # v0 = dy*dy
    jal fpn_sqrt
      addu a0, v0, s0 # v0 = sqrt(dx^2 + dy^2)
    lw  ra, 0(sp)
    lw  s0, 4(sp)
    jr ra
      addiu sp, sp, 8


UTEST_dist:
    li a0, 0x327439
    li a1, 0xfffff980
    li a2, 0xffa8c51f
    li a3, TB_dist
    j  0x80001830
      nop


TB_gravity:
    /* compute unit gravity acceleration between two positions
    input:
      a0: fpn from.x
      a1: fpn from.y
      a2: fpn to.x
      a3: fpn to.y
    output:
      v0: fpn a.x
      v1: fpn a.y
    */
    addiu sp, sp, -4
    sw    ra, 0(sp)
    move  t6, a0  # notice t6 - t9 cannot be affected by mul / div
    jal   TB_dist # a2, a3 unaffected
      move t7, a1
    # v0 == dist
    # lw ra, 0(sp)
    # jr ra
    #   addiu sp, sp, 4


    move a0, v0
    jal  fpn_mul
      move a1, v0
    # v0 == dist^2, a1 == dist
    jal  fpn_mul
      move a0, v0
    # v0 == dist^3
    move v0, t8  # t8 = denom

    # lw ra, 0(sp)
    # jr ra
    #   addiu sp, sp, 4

    subu a0, a3, t7 # a0 = dy
    jal fpn_div
      move a1, t8
    move v1, v0 # v1 = ay = dy / denom

    subu a0, a2, t6 # a0 = dx
    jal  fpn_div
      move a1, t8 # v0 = ax = dx / denom
    
    lw ra, 0(sp)
    jr ra
      addiu sp, sp, 4


UTEST_gravity:
    li a0, 0x147439
    li a1, 0xfffff980
    li a2, 0xffa8c51f
    li a3, 0xfffe0000
    j TB_gravity
      nop

