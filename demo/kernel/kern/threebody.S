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
    li a0, 0x147439
    li a1, 0xfffff980
    li a2, 0xfff5c51f
    li a3, 0xfffe0000
    j  TB_dist
      nop # v0 should be 0x001ebf5a


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
    addiu sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)

    move  s0, a0  # s0 = from.x
    jal   TB_dist
      move  s1, a1  # s1 = from.y
    # v0 == dist

    move a0, v0
    jal  fpn_mul
      move a1, v0
    # v0 == dist^2, a1 == dist
    jal  fpn_mul
      move a0, v0
    # v0 == dist^3
    move s2, v0  # s2 = denom

    subu a0, a3, s1 # a0 = dy
    jal fpn_div
      move a1, s2  # ***** the value of v0 v1 here is not stable over time, very strange bug!!

    move v1, v0 # v1 = ay = dy / denom

    subu a0, a2, s0 # a0 = dx
    jal  fpn_div
      move a1, s2 # v0 = ax = dx / denom
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    jr ra
      addiu sp, sp, +16


UTEST_gravity:
    li a0, 0xfff5d375
    li a1, 0x8d8ad
    li a2, 0x4106
    li a3, 0xfffef72c
    j TB_gravity
      nop
    # v0 should be 0x7a57
    # v1 should be 0xffffefe3
    # t8 should be 0x2fcf6   ok

# UTEST_div_:
#     li a0, 0xffffcfd9
#     li a1, 0x0002fce6
#     j fpn_div
#       nop
#     # v0 should be 0xffffefe3


TB_step:
    /* simulate one step
    input:
      a0: fpn time step
    global:
      r1, r2, r3, v1, v2, v3: 6 * 2(x, y) * 32bit
    */
    addiu sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    move s0, a0  # s0 stores dt

    lw a0, TB_r1x(zero)
    lw a1, TB_r1y(zero)
    lw a2, TB_r2x(zero)
    lw a3, TB_r2y(zero)
    jal TB_gravity  # f12
      nop

    # s1 - s2: a1
    move s1, v0
    move s2, v1
    # s3 - s4: a2
    subu s3, zero, v0
    subu s4, zero, v1
    
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addiu sp, sp, +32
    jr ra
      nop
