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

# li $a0, 0x327439
# li $a1, 0xfffff980
# li $a2, 0xffa8c51f
# li $a3, 0xfffe0000
# j  0x80001830
#   nop


