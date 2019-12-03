#ifndef _DEMO_H
#define _DEMO_H

#define DEMO_WELCOME_IMG_ADDR 0x80400000
#define DEMO_TB_IMG_ADDR      0x80475300

#define SQRT_ITER_TIME  10

#define TB_r1x  0x80700000
#define TB_r1y  0x80700004
#define TB_r2x  0x80700008
#define TB_r2y  0x8070000c
#define TB_r3x  0x80700010
#define TB_r3y  0x80700014

#define TB_v1x  0x80700020
#define TB_v1y  0x80700024
#define TB_v2x  0x80700028
#define TB_v2y  0x8070002c
#define TB_v3x  0x80700030
#define TB_v3y  0x80700034

#define TB_r2x_init  0x0
#define TB_r2y_init  0x10000
#define TB_r1x_init  0xddb3
#define TB_r1y_init  0xffff8000
#define TB_r3x_init  0xffff224d
#define TB_r3y_init  0xffff8000

#define TB_v1x_init  0xffffd70b
#define TB_v1y_init  0xffffeb86
#define TB_v2x_init  0xffffb232
#define TB_v2y_init  0xffff793c
#define TB_v3x_init  0xffffb232
#define TB_v3y_init  0x86c4

#define TB_LINEW 3

#endif
