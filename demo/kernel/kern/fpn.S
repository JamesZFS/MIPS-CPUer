#include <regdef.h>
#include <mipsregs.h>
#include <unistd.h>

    .set noreorder
    .set noat
    .p2align 2
    .text

    .equ W, 1<<16

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
      nop
    div zero, a, b
    mflo c
    sll c, c, 16  # q
    mfhi r
    li i, 15
    li d, 0
    .div_loop:
        beqz r, .div_finally # if r == 0: break
          nop
        sll r, r, 1  # r <<= 1
        sll d, d, 1  # d <<= 1
        sub t3, r, b  # try r - b
        # bltz t3, .div_loop_final # r < b
        beqz t3, .div_plus_d # r >= b
          nop
        bgtz t3, .div_plus_d
          nop
        j .div_loop_final
          nop
        
        .div_plus_d:  # r / b
        addiu d, d, 1 # d += r / b
        r = t3  # r = r % b
        
        .div_loop_final:
        addiu i, i, -1
        bnez i, .div_loop
          nop

    .div_finally:
    jr ra
    add c, c, d
    #undef i
    #undef r
    #undef d

    .div_by_zero:
        li v0, SYS_nan
        syscall SYSCALL_BASE
        nop
        nop

#undef a
#undef b
#undef c

# li $a0, 0x17a522d
# li $a1, 0x24fdf
# j 0x800011ec
# nop
