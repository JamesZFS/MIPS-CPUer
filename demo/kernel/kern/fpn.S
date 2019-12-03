#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>
#include <demo.h>

    .set noreorder
    .set noat
    .section .text.fpn
    .p2align 2

    .global fpn_mul
    .global fpn_div
    .global fpn_sqrt

// 32-bit signed fixed point number module
// integer part: 16-bit signed, decimal: 16-bit unsigned
// add, sub is the same as common integer computation

fpn_mul:
    /* multiply two fpn
    input:
        a0: fpn of a
        a1: fpn of b
    output:
        v0: fpn[a * b]
    */
    mult a0, a1  # 64-bit result
    mfhi v0
    sll  v0, v0, 16
    mflo t0
    srl  t0, t0, 16
    addu v0, v0, t0
    jr   ra
      nop

fpn_div:
    /* divide two fpn, no remainder
    input:
        a0: fpn of a
        a1: fpn of b
    output:
        v0: fpn[a / b]
    */
    beqz a1, .div_by_zero
      nop
    lui t5, 0x8000
    and t3, a0, t5 # get sign bit
    beqz t3, .div_a_pos
      nop
    subu a0, zero, a0 # a = -a
    li t4, 0x1 # sign flag

    .div_a_pos:
    and t3, a1, t5 # get sign bit
    beqz t3, .div_a_b_pos
      nop
    subu a1, zero, a1 # b = -b
    xori t4, t4, 0x1 # sign flag

    .div_a_b_pos:
    divu zero, a0, a1
    mflo v0
    sll v0, v0, 16  # q
    mfhi t1
    li t0, 16
    li t2, 0

    .div_loop:
        # beqz r, .div_finally # if r == 0: break
        sll t1, t1, 1  # r <<= 1
        sll t2, t2, 1  # d <<= 1
        subu t3, t1, a1  # try r - b
        bltz t3, .div_loop_final # r < b
          nop
        
        .div_plus_d:  # r / b
        addiu t2, t2, 1 # d += r / b
        move  t1, t3  # r = r % b

        .div_loop_final:
        addiu t0, t0, -1
        bnez t0, .div_loop
          nop

    .div_finally:
    addu v0, v0, t2
    beqz t4, .div_ret  # if a and b share the same sign, just return
      nop
    subu v0, zero, v0 # else, flip ans if signed
    nop

    .div_ret:
    jr ra
      nop
    nop
    nop

    .div_by_zero:
    li v0, SYS_nan
    syscall SYSCALL_BASE
    nop
    jr ra
    nop

UTEST_div:
    li a0, 0xffffcfd9
    li a1, 0x0002fce6
    j fpn_div
      nop
    # v0 should be 0xffffefe3
    nop


fpn_sqrt:
    /* sqrt using Newton iteration method
    input:
        a0: fpn of a
    output:
        v0: fpn[sqrt(a)]
    */
    bgtz a0, .sqrt_common
      nop
    bltz a0, .sqrt_neg # nan
      li v0, 0
    jr ra # return 0
      nop

    .sqrt_common:
    addiu sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    srl s0, a0, 1  # x0 = a / 2
    move s1, a0  # backup a
    li s2, SQRT_ITER_TIME
    .sqrt_loop:
        move a0, s1
        move a1, s0
        jal fpn_div # v0 = a / x
          # addu v0, a0, a1
          nop
        addu s0, s0, v0
        addiu s2, s2, -1
        srl s0, s0, 1 # x' = (x + a/x) / 2
        bnez s2, .sqrt_loop
          nop
          
    move v0, s0
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addiu sp, sp, 16
    jr   ra
      nop

    .sqrt_neg:
    nop
    j .sqrt_neg
      nop
    li v0, SYS_nan
    syscall SYSCALL_BASE
    nop
    jr ra
    nop

