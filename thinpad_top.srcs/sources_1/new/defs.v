// global
`define RstEnable       1'b1
`define RstDisable      1'b0
`define ZeroWord        32'h00000000
`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0
`define AluOpBus        3:0
`define AluSelBus       2:0
`define InstValid       1'b1
`define InstInvalid     1'b0
`define True_v          1'b1
`define False_v         1'b0
`define ChipEnable      1'b1
`define ChipDisable     1'b0
`define StallEnable     1'b1 // stop
`define StallDisable    1'b0 // continue
`define RAMEnable       1'b0
`define RAMDisable      1'b1

// instrcution macros -- first 6 bits
`define EXE_AND         6'b100100 // special
`define EXE_ANDI        6'b001100
`define EXE_OR          6'b100101 // special
`define EXE_ORI         6'b001101
`define EXE_XOR         6'b100110 // special
`define EXE_XORI        6'b001110

`define EXE_SLL         6'b000000 // special
`define EXE_SRL         6'b000010 // special

`define EXE_MOVZ        6'b001010 // special

`define EXE_ADDU        6'b100001 // special
`define EXE_ADDIU       6'b001001
`define EXE_CLZ         6'b100000 // special2

`define EXE_LUI         6'b001111

`define EXE_NOP         6'b000000
`define EXE_SPECIAL     6'b000000
`define EXE_SPECIAL2    6'b011100


// alu operation
`define EXE_AND_OP      4'd1
`define EXE_OR_OP       4'd2
`define EXE_XOR_OP      4'd3

`define EXE_SLL_OP      4'd4
`define EXE_SRL_OP      4'd5

`define EXE_MOVZ_OP     4'd6

`define EXE_ADDU_OP     4'd7
`define EXE_CLZ_OP      4'd8

`define EXE_LUI_OP      4'd9

`define EXE_NOP_OP      4'd0


// alu result selection
`define EXE_RES_LOGIC   3'd1
`define EXE_RES_SHIFT   3'd2
`define EXE_RES_MOVE    3'd3
`define EXE_RES_ARITH   3'd4
`define EXE_RES_LOAD    3'd5

`define EXE_RES_NOP     3'd0

// TODO: ROM ?
`define InstAddrBus     31:0
`define InstAddrLog2    32
`define InstBus         31:0
`define InstMemNum      131071
`define InstMemNumLog2  17

// Registers macros
`define RegAddrBus      4:0
`define RegBus          31:0
`define RegWidth        32
`define DoubleRegWidth  64
`define DoubleRegBus    63:0
`define RegNum          32
`define RegNumLog2      5
`define NOPRegAddr      5'b00000

