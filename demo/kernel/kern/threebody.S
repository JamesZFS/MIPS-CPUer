#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>
#include <demo.h>

    .set noreorder
    # .set noat
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

  // prepare

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

  // compute accelarations:

    lw a0, TB_r1x(zero)
    lw a1, TB_r1y(zero)
    lw a2, TB_r2x(zero)
    lw a3, TB_r2y(zero)
    jal TB_gravity  # v0-v1: f12
      nop

    # s1 - s2: a1
    move s1, v0 # a1.x = f.x
    move s2, v1 # a1.y = f.y
    # s3 - s4: a2
    subu s3, zero, v0 # a2.x = -f.x
    subu s4, zero, v1

    lw a0, TB_r2x(zero)
    lw a1, TB_r2y(zero)
    lw a2, TB_r3x(zero)
    lw a3, TB_r3y(zero)
    jal TB_gravity  # v0-v1: f23
      nop
    
    # s3 - s4: a2
    addu s3, s3, v0  # a2.x += f.x
    addu s4, s4, v1
    # s5 - s6: a3
    subu s5, zero, v0 # a3.x = -f.x
    subu s6, zero, v1

    lw a0, TB_r3x(zero)
    lw a1, TB_r3y(zero)
    lw a2, TB_r1x(zero)
    lw a3, TB_r1y(zero)
    jal TB_gravity  # v0-v1: f31
      nop

    # s5 - s6: a3
    addu s5, s5, v0 # a3.x += f.x
    addu s6, s6, v1
    # s1 - s2: a1
    subu s1, s1, v0 # a1.x -= f.x
    subu s2, s2, v1

  // update velocities:

    # v1:
    move a0, s1 # a1.x
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is a1.x * dt
    lw s1, TB_v1x(zero)
    addu s1, s1, v0    # now s1 is v1.x
    sw s1, TB_v1x(zero)

    move a0, s2 # a1.y
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is a1.y * dt
    lw s2, TB_v1y(zero)
    addu s2, s2, v0    # now s2 is v1.y
    sw s2, TB_v1y(zero)

    # v2:
    move a0, s3 # a2.x
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is a2.x * dt
    lw s3, TB_v2x(zero)
    addu s3, s3, v0    # now s3 is v2.x
    sw s3, TB_v2x(zero)

    move a0, s4 # a2.y
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is a2.y * dt
    lw s4, TB_v2y(zero)
    addu s4, s4, v0    # now s4 is v2.y
    sw s4, TB_v2y(zero)

    # v3:
    move a0, s5 # a3.x
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is a3.x * dt
    lw s5, TB_v3x(zero)
    addu s5, s5, v0    # now s5 is v3.x
    sw s5, TB_v3x(zero)

    move a0, s6 # a3.y
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is a3.y * dt
    lw s6, TB_v3y(zero)
    addu s6, s6, v0    # now s6 is v3.y
    sw s6, TB_v3y(zero)

  // update positions:

    # v1:
    move a0, s1 # v1.x
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is v1.x * dt
    lw s1, TB_r1x(zero)
    addu s1, s1, v0    # now s1 is r1.x
    sw s1, TB_r1x(zero)

    move a0, s2 # v1.y
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is a1.y * dt
    lw s2, TB_r1y(zero)
    addu s2, s2, v0    # now s2 is r1.y
    sw s2, TB_r1y(zero)

    # v2:
    move a0, s3 # v2.x
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is v2.x * dt
    lw s3, TB_r2x(zero)
    addu s3, s3, v0    # now s3 is r2.x
    sw s3, TB_r2x(zero)

    move a0, s4 # v2.y
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is v2.y * dt
    lw s4, TB_r2y(zero)
    addu s4, s4, v0    # now s4 is r2.y
    sw s4, TB_r2y(zero)

    # v3:
    move a0, s5 # v3.x
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is v3.x * dt
    lw s5, TB_r3x(zero)
    addu s5, s5, v0    # now s5 is r3.x
    sw s5, TB_r3x(zero)

    move a0, s6 # v3.y
    move a1, s0 # dt
    jal fpn_mul
      nop # v0 is v3.y * dt
    lw s6, TB_r3y(zero)
    addu s6, s6, v0    # now s6 is r3.y
    sw s6, TB_r3y(zero)

    # finish computing.

  // recover and ret
    
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
