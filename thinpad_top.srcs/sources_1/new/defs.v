// ** cpu config **
`define ON_FPGA
`define CPU_CLK clk_10M

// global
`define RstEnable       1'b1
`define RstDisable      1'b0
`define ZeroWord        32'h00000000
`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0
`define AluOpBus        5:0
`define AluSelBus       3:0
`define InstValid       1'b0
`define InstInvalid     1'b1
`define True_v          1'b1
`define False_v         1'b0
`define ChipEnable      1'b1
`define ChipDisable     1'b0
`define StallEnable     1'b1 // stop
`define StallDisable    1'b0 // continue
`define RAMEnable       1'b0
`define RAMDisable      1'b1
`define UARTEnable      1'b0
`define UARTDisable     1'b1
`define Branch          1'b1 //jump
`define NotBranch       1'b0 //no jump
`define InDelaySlot     1'b1 //in slot
`define NotInDelaySlot  1'b0 //not in slot
`define IsImm           1'b1
`define IsNotImm        1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0

`define PC_INIT         32'h80000000
`define EHANDLERLOCATE  32'h80001180

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

`define EXE_ADD         6'b100000 // special
`define EXE_ADDU        6'b100001 // special
`define EXE_ADDIU       6'b001001
`define EXE_SUB         6'b100010
`define EXE_SUBU        6'b100011 //special

`define EXE_MULT  6'b011000
`define EXE_MULTU  6'b011001
`define EXE_MUL  6'b000010

`define EXE_MFHI  6'b010000
`define EXE_MTHI  6'b010001
`define EXE_MFLO  6'b010010
`define EXE_MTLO  6'b010011

`define EXE_CLZ         6'b100000 // special2

`define EXE_LUI         6'b001111

`define EXE_NOP         6'b000000
`define EXE_SPECIAL     6'b000000
`define EXE_SPECIAL2    6'b011100
`define EXE_REGIMM_INST 6'b000001


//jmp instruction operations
`define EXE_J  6'b000010 
`define EXE_JAL  6'b000011 
`define EXE_JR  6'b001000
`define EXE_BEQ  6'b000100
`define EXE_BGTZ  6'b000111
`define EXE_BGEZ  5'b00001
`define EXE_BLTZ  5'b00000
`define EXE_BLEZ  6'b000110
`define EXE_BNE  6'b000101

//Load & Store instruction operations
`define EXE_LB          6'b100000
`define EXE_LBU         6'b100100
`define EXE_LW          6'b100011
`define EXE_SW          6'b101011
`define EXE_SB          6'b101000
`define EXE_TEQ         6'b110100
`define EXE_TEQI        5'b01100
`define EXE_TGE         6'b110000
`define EXE_TGEI        5'b01000
`define EXE_TGEIU       5'b01001
`define EXE_TGEU        6'b110001
`define EXE_TLT         6'b110010
`define EXE_TLTI        5'b01010
`define EXE_TLTIU       5'b01011
`define EXE_TLTU        6'b110011
`define EXE_TNE         6'b110110
`define EXE_TNEI        5'b01110
`define EXE_SYSCALL     6'b001100
`define EXE_ERET        32'b01000010000000000000000000011000
`define EXE_DIV  6'b011010
`define EXE_DIVU  6'b011011

//new op

`define EXE_LWPC   6'b111011



// alu operations:
`define EXE_NOP_OP      6'd0

`define EXE_AND_OP      6'd1
`define EXE_OR_OP       6'd2
`define EXE_XOR_OP      6'd3

`define EXE_SLL_OP      6'd4
`define EXE_SRL_OP      6'd5

`define EXE_MOVZ_OP     6'd6

`define EXE_ADDU_OP     6'd7
`define EXE_CLZ_OP      6'd8

`define EXE_LUI_OP      6'd9

`define EXE_SUBU_OP     6'd10
`define EXE_MULT_OP     6'd11
`define EXE_MULTU_OP    6'd12
`define EXE_MUL_OP      6'd13

//jump operations
`define EXE_J_OP        6'd14
`define EXE_JAL_OP      6'd15
`define EXE_JR_OP       6'd16
`define EXE_BEQ_OP      6'd17
`define EXE_BGTZ_OP     6'd18
`define EXE_BGEZ_OP     6'd19
`define EXE_BLTZ_OP     6'd20
`define EXE_BLEZ_OP     6'd21
`define EXE_BNE_OP      6'd22

//Load & Store operations
`define EXE_LB_OP       6'd23
`define EXE_LBU_OP      6'd24
`define EXE_LW_OP       6'd25
`define EXE_SW_OP       6'd26
`define EXE_SB_OP       6'd27

// hi-lo
`define EXE_MFHI_OP  6'd28
`define EXE_MTHI_OP  6'd29
`define EXE_MFLO_OP  6'd30
`define EXE_MTLO_OP  6'd31
`define EXE_DIV_OP   6'd32
`define EXE_DIVU_OP  6'd33

//cp0 operations
`define EXE_MFC0_OP    6'd34
`define EXE_MTC0_OP    6'd35
`define EXE_SYSCALL_OP 6'd36
`define EXE_ERET_OP    6'd37

`define EXE_LWPC_OP     6'd38


// alu result selection
`define EXE_RES_LOGIC   4'd1
`define EXE_RES_SHIFT   4'd2
`define EXE_RES_MOVE    4'd3
`define EXE_RES_ARITH   4'd4
`define EXE_RES_LOAD    4'd5
`define EXE_RES_JUMP_BRANCH 4'd6
`define EXE_RES_LOAD_STORE 4'd7
`define EXE_RES_MUL     4'd8

`define EXE_RES_NOP     4'd0

// inst-sram
`define InstAddrBus     31:0
`define InstAddrLog2    32
`define InstBus         31:0


// Registers macros
`define RegAddrBus      4:0
`define RegBus          31:0
`define RegWidth        32
`define DoubleRegWidth  64
`define DoubleRegBus    63:0
`define RegNum          32
`define RegNumLog2      5
`define NOPRegAddr      5'b00000

`define CP0_REG_STATUS   5'd12     
`define CP0_REG_CAUSE    5'd13       
`define CP0_REG_EPC      5'd14         
`define CP0_REG_EBASE    5'd15        

//***definitions related to division***
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

// DVI
`define BRAMEnable      1'b1
`define BRAMDisable     1'b0
`define RED             3'b111
`define GREEN           3'b111
`define BLUE            2'b11
`define BLACK           0

// Flash
`define FlashEnable     1'b0 
`define FlashDisable    1'b1 
