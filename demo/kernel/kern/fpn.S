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

#define a a0
#define b a1
#define c v0
fpn_mul:
    /* multiply two fpn
    input:
        a0: fpn of a
        a1: fpn of b
    output:
        v0: fpn[a * b]
    */
    mult a, b  # 64-bit result
    mfhi c
    sll  c, c, 16
    mflo t0
    srl  t0, t0, 16
    jr   ra
    add  c, c, t0

fpn_div:
    /* divide two fpn, no remainder
    input:
        a0: fpn of a
        a1: fpn of b
    output:
        v0: fpn[a / b]
    */
    #define i t0
    #define r t1
    #define d t2
    beqz b, .div_by_zero
      lui t5, 0x8000
    and t3, a, t5 # get sign bit
    beqz t3, .div_a_pos
      nop
    sub a, zero, a # a = -a
    li t4, 0x1 # sign flag

    .div_a_pos:
    and t3, b, t5 # get sign bit
    beqz t3, .div_a_b_pos
      nop
    sub b, zero, b # a = -a
    xori t4, 0x1 # sign flag

    .div_a_b_pos:
    div zero, a, b
    mflo c
    sll c, c, 16  # q
    mfhi r
    li i, 16
    li d, 0
    .div_loop:
        # beqz r, .div_finally # if r == 0: break
        sll r, r, 1  # r <<= 1
        sll d, d, 1  # d <<= 1
        sub t3, r, b  # try r - b
        bltz t3, .div_loop_final # r < b
          nop
        
        .div_plus_d:  # r / b
        addiu d, d, 1 # d += r / b
        move  r, t3  # r = r % b

        .div_loop_final:
        addiu i, i, -1
        bnez i, .div_loop
          nop

    .div_finally:
    # sllv  d, d, i // TODO
    beqz t4, .div_ret
      add c, c, d
    sub c, zero, c # flip ans if signed

    .div_ret:
    jr ra
      nop
    #undef i
    #undef r
    #undef d

    .div_by_zero:
    li v0, SYS_nan
    syscall SYSCALL_BASE
    nop
    jr ra
    nop

#undef a
#undef b
#undef c

# li $a0, 0xc87439
# li $a1, 0xfffff980
# j 0x800011d0
# nop

fpn_sqrt:
    /* sqrt using Newton iteration method
    input:
        a0: fpn of a
    output:
        v0: fpn[sqrt(a)]
    */
    #define x s0
    #define a s1
    #define i s2
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
    srl x, a0, 1  # x0 = a / 2
    move a, a0  # backup a
    li i, SQRT_ITER_TIME
    .sqrt_loop:
        move a0, a
        jal fpn_div # v0 = a / x
          move a1, x
        add x, x, v0
        addiu i, i, -1
        bnez i, .sqrt_loop
          srl x, x, 1 # x' = (x + a/x) / 2
          
    move v0, x
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    jr   ra
      addiu sp, sp, 16

    #undef x
    #undef a
    #undef i
    .sqrt_neg:
    li v0, SYS_nan
    syscall SYSCALL_BASE
    nop
    jr ra
    nop

# li $a0, 0x303c0588
# j 0x80001284
#  nop
