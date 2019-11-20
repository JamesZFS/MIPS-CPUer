module ex(
    input   wire  rst,
	
    // signals from id
    input wire[`AluOpBus]         aluop_i,
    input wire[`AluSelBus]        alusel_i,
    input wire[`RegBus]           reg1_i,
    input wire[`RegBus]           reg2_i,
    input wire[`RegAddrBus]       wd_i,
    input wire[`RegBus]           link_address_i,
    input wire                    is_in_delayslot_i,
    input wire                    wreg_i,
    
    // propagate result to mem (and forward to id)
    output reg                    wreg_o,
    output reg[`RegAddrBus]       wd_o,
    output reg[`RegBus]           wdata_o,

    // to ctrl
    output reg                    stallreq_o
);

reg[`RegBus]    logic_res;
reg[`RegBus]    shift_res;
reg[`RegBus]    move_res;
reg[`RegBus]    arith_res;
reg[`RegBus]    load_res;

wire[`RegBus]   sum_res = reg1_i + reg2_i;
// assign          sum_res = reg1_i + reg2_i;

always @ * begin    // perform logical computation
    if (rst == `RstEnable) begin
        logic_res <= `ZeroWord;
    end else begin
        case (aluop_i)      // ** case various alu operations **

            `EXE_OR_OP: logic_res <= reg1_i | reg2_i;

            `EXE_AND_OP: logic_res <= reg1_i & reg2_i;
            
            `EXE_XOR_OP: logic_res <= reg1_i ^ reg2_i;

            default: logic_res <= `ZeroWord;
            
        endcase
    end
end

always @ * begin    // perform shift computation
    if (rst == `RstEnable) begin
        shift_res <= `ZeroWord;
    end else begin
        case (aluop_i)      // ** case various alu operations **

            `EXE_SLL_OP: shift_res <= reg1_i << reg2_i[4:0]; // shift less than 32 bits

            `EXE_SRL_OP: shift_res <= reg1_i >> reg2_i[4:0];

            default: shift_res <= `ZeroWord;
            
        endcase
    end
end

always @ * begin    // perform arithmetic computation
    if (rst == `RstEnable) begin
        arith_res <= `ZeroWord;
    end else begin
        case (aluop_i)      // ** case various alu operations **

            `EXE_ADDU_OP:
                arith_res <= sum_res;

            `EXE_CLZ_OP:  // count leading zeros in reg_1
                arith_res <= 
                    reg1_i[31]? 0  : reg1_i[30]? 1  : reg1_i[29]? 2  :
                    reg1_i[28]? 3  : reg1_i[27]? 4  : reg1_i[26]? 5  :
                    reg1_i[25]? 6  : reg1_i[24]? 7  : reg1_i[23]? 8  : 
                    reg1_i[22]? 9  : reg1_i[21]? 10 : reg1_i[20]? 11 :
                    reg1_i[19]? 12 : reg1_i[18]? 13 : reg1_i[17]? 14 : 
                    reg1_i[16]? 15 : reg1_i[15]? 16 : reg1_i[14]? 17 : 
                    reg1_i[13]? 18 : reg1_i[12]? 19 : reg1_i[11]? 20 :
                    reg1_i[10]? 21 : reg1_i[9]?  22 : reg1_i[8]?  23 : 
                    reg1_i[7]?  24 : reg1_i[6]?  25 : reg1_i[5]?  26 : 
                    reg1_i[4]?  27 : reg1_i[3]?  28 : reg1_i[2]?  29 : 
                    reg1_i[1]?  30 : reg1_i[0]?  31 : 32;

            default: arith_res <= `ZeroWord;
            
        endcase
    end
end

always @ * begin    // perform moving
    if (rst == `RstEnable) begin
        move_res <= `ZeroWord;
    end else begin
        case (aluop_i)

            `EXE_MOVZ_OP: move_res <= reg1_i;   // write or not is determined by wreg_o in id stage

            default: move_res <= `ZeroWord;
            
        endcase
    end
end

always @ * begin    // perform loading
    if (rst == `RstEnable) begin
        load_res <= `ZeroWord;
    end else begin
        case (aluop_i)

            `EXE_LUI_OP: load_res <= reg1_i; // imm || 0^16

            default: load_res <= `ZeroWord;
            
        endcase
    end
end


always @ * begin    // generate write signal
    if (rst == `RstEnable) begin      //  TODO: block this case or not?
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        case (alusel_i)     // alu result selection

            `EXE_RES_LOGIC: wdata_o <= logic_res; 

            `EXE_RES_SHIFT: wdata_o <= shift_res;

            `EXE_RES_MOVE: wdata_o <= move_res;

            `EXE_RES_ARITH: wdata_o <= arith_res;

            `EXE_RES_LOAD: wdata_o <= load_res;

            `EXE_RES_JUMP_BRANCH: wdata_o <= link_address_i;

            default: wdata_o <= `ZeroWord;

        endcase
    end
end

// pipeline stalling demo:
/* parameter UNSTALLED = 1'd0, STALLED = 1'd1;
reg cur_state;

always @(posedge clk) begin
    if (rst == `RstEnable)
        cur_state <= UNSTALLED;
    else if (aluop_i == `EXE_ADDU_OP) begin
        if (cur_state == UNSTALLED) begin
            cur_state <= STALLED;
        end else begin
            cur_state <= UNSTALLED;
        end
    end else
        cur_state <= UNSTALLED;
end
*/

always @* begin
    if (rst == `RstEnable)
        stallreq_o <= `StallDisable;
    // else if (aluop_i == `EXE_ADDU_OP) begin
    //     if (cur_state == UNSTALLED) begin
    //         stallreq_o <= `StallEnable;  // TODO: just for tets
    //     end else begin
    //         stallreq_o <= `sStallDisable;
    //     end
    // end
    else
        stallreq_o <= `StallDisable;
end


endmodule // ex