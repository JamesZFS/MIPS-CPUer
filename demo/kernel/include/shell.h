#ifndef _MONITOR_SHELL_H
#define _MONITOR_SHELL_H

#define SH_OP_R 0x0052              // char 'R'
#define SH_OP_D 0x0044              // char 'D'
#define SH_OP_A 0x0041              // char 'A'
#define SH_OP_G 0x0047              // char 'G'
#define SH_OP_T 0x0054              // char 'T'
#define SH_OP_P 0x0050              // char 'P'

#define PUTREG(r)  ((r - 1) << 2)

#define TIMERSET    0x06            // ascii (ACK) 启动计时
#define TIMETOKEN   0x07            // ascii (BEL) 停止计时

#define TK_FATAL    0x80            // fatal error
#define TK_INVALID  0x90            // invalid instruction
#define TK_NAN      0x91            // div by zero
#define TK_DEBUG_W  0x92            // send debug number to term (word)

#endif
