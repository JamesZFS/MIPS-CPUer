// global
`define RstEnable       1'b1
`define RstDisable      1'b0
`define ZeroWord        32'h00000000
`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0
`define AluOpBus        4:0
`define AluSelBus       2:0
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
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0

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
`define EXE_REGIMM_INST 6'b000001


//jmp instruction operations
`define EXE_J  6'b000010 
`define EXE_JAL  6'b000011 
`define EXE_JR  6'b001000
`define EXE_BEQ  6'b000100
`define EXE_BGTZ  6'b000111
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



// alu operations:
`define EXE_NOP_OP      5'h0

`define EXE_AND_OP      5'h1
`define EXE_OR_OP       5'h2
`define EXE_XOR_OP      5'h3

`define EXE_SLL_OP      5'h4
`define EXE_SRL_OP      5'h5

`define EXE_MOVZ_OP     5'h6

`define EXE_ADDU_OP     5'h7
`define EXE_CLZ_OP      5'h8

`define EXE_LUI_OP      5'h9

//jump operations
`define EXE_J_OP        5'ha
`define EXE_JAL_OP      5'hb
`define EXE_JR_OP       5'hc
`define EXE_BEQ_OP      5'hd
`define EXE_BGTZ_OP     5'he
`define EXE_BNE_OP      5'hf

//Load & Store operations
`define EXE_LB_OP       5'h10
`define EXE_LBU_OP      5'h11
`define EXE_LW_OP       5'h12
`define EXE_SW_OP       5'h13
`define EXE_SB_OP       5'h14

//MMU
// `define MemOccupy       1'd1
// `define MemAddrStart    0x


//cp0 operations
`define EXE_MFC0_OP 5'd16
`define EXE_MTC0_OP 5'd17

`define EXE_TEQ_OP 5'd18
`define EXE_TEQI_OP 5'd19
`define EXE_TGE_OP 5'd20
`define EXE_TGEI_OP 5'd21
`define EXE_TGEIU_OP 5'd22
`define EXE_TGEU_OP 5'd23
`define EXE_TLT_OP 5'd24
`define EXE_TLTI_OP 5'd25
`define EXE_TLTIU_OP 5'd26
`define EXE_TLTU_OP 5'd27
`define EXE_TNE_OP 5'd28
`define EXE_TNEI_OP 5'd29
`define EXE_SYSCALL_OP 5'd30

`define EXE_ERET_OP 5'd31

// alu result selection
`define EXE_RES_LOGIC   3'd1
`define EXE_RES_SHIFT   3'd2
`define EXE_RES_MOVE    3'd3
`define EXE_RES_ARITH   3'd4
`define EXE_RES_LOAD    3'd5
`define EXE_RES_JUMP_BRANCH 3'd6
`define EXE_RES_LOAD_STORE 3'd7


`define EXE_RES_NOP     3'd0

// inst-sram
`define InstAddrBus     31:0
`define InstAddrLog2    32
`define InstBus         31:0
// `define InstMemNum      131071
// `define InstMemNumLog2  17

// Registers macros
`define RegAddrBus      4:0
`define RegBus          31:0
`define RegWidth        32
`define DoubleRegWidth  64
`define DoubleRegBus    63:0
`define RegNum          32
`define RegNumLog2      5
`define NOPRegAddr      5'b00000

`define CP0_REG_COUNT    5'b01001       
`define CP0_REG_COMPARE    5'b01011     
`define CP0_REG_STATUS    5'b01100      
`define CP0_REG_CAUSE    5'b01101       
`define CP0_REG_EPC    5'b01110         
`define CP0_REG_PrId    5'b01111        
`define CP0_REG_CONFIG    5'b10000   

// DVI
`define HVDataWidth     12
`define HVDataBus       11:0
`define RED             3'b111
`define GREEN           3'b111
`define BLUE            2'b11
`define BLACK           0
