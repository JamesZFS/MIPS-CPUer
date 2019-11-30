module ex(
    input   wire  rst,
	
    // signals from id
    input wire[`AluOpBus]         aluop_i,
    input wire[`AluSelBus]        alusel_i,
    input wire[`RegAddrBus]       reg1_addr_i,
	input wire[`RegAddrBus]       reg2_addr_i, 
    input wire[`RegBus]           reg1_i,
    input wire[`RegBus]           reg2_i,
    input wire[`RegAddrBus]       wd_i,
    input wire[`RegBus]           link_address_i,
    input wire                    is_in_delayslot_i,
    input wire                    wreg_i,
    input wire[`RegBus]           inst_i,
    input wire                    reg1_is_imm,
    input wire                    reg2_is_imm,

    // from mem  ** a variant of conflict type 1
    input wire                    mem_is_load_i, // only handle load type conflict
    input wire[`RegAddrBus]       mem_wd_i,  // which reg may be conflicting?
    input wire[`RegBus]           mem_wdata_i,
    input wire[31:0]              excepttype_i,
	input wire[`RegBus]           current_inst_address_i,


    input wire                    mem_cp0_reg_we,
	input wire[4:0]               mem_cp0_reg_write_addr,
	input wire[`RegBus]           mem_cp0_reg_data,

    input wire                    wb_cp0_reg_we,
	input wire[4:0]               wb_cp0_reg_write_addr,
	input wire[`RegBus]           wb_cp0_reg_data,

    input wire[`RegBus]           cp0_reg_data_i,
	output reg[4:0]               cp0_reg_read_addr_o,

	input wire[`RegBus]           wb_hi_i,
	input wire[`RegBus]           wb_lo_i,
	input wire                    wb_whilo_i,
	
	input wire[`RegBus]           mem_hi_i,
	input wire[`RegBus]           mem_lo_i,
	input wire                    mem_whilo_i,
    
    // propagate result to mem (and forward to id)
    output reg                    wreg_o,
    output reg[`RegAddrBus]       wd_o,
    output reg[`RegBus]           wdata_o,
    output wire                   is_load_o,  // back to id

    output wire[`AluOpBus]        aluop_o,
    output wire[`RegBus]          mem_addr_o,
    output wire[`RegBus]          reg2_o,

    output reg                    cp0_reg_we_o,
	output reg[4:0]               cp0_reg_write_addr_o,
	output reg[`RegBus]           cp0_reg_data_o,

    //to ex/mem
	output wire[31:0]             excepttype_o,
	output wire                   is_in_delayslot_o,
	output wire[`RegBus]          current_inst_address_o,

    output reg[`RegBus]           hi_o,
	output reg[`RegBus]           lo_o,
	output reg                    whilo_o,	

    //from hi/lo
    input wire[`RegBus]           hi_i,
	input wire[`RegBus]           lo_i,

    // to ctrl
    output reg                    stallreq_o
);

reg[`RegBus]    logic_res;
reg[`RegBus]    shift_res;
reg[`RegBus]    move_res;
reg[`RegBus]    arith_res;
reg[`DoubleRegBus] mulres;	
reg[`RegBus]    load_res;
reg[`RegBus] HI;
reg[`RegBus] LO;
wire trapassert = 1'b0; // unimplemented
wire ovassert   = 1'b0; // unimplemented
wire[`RegBus] reg2_i_mux;
wire[`DoubleRegBus] hilo_temp;
wire[`RegBus] opdata1_mult;
wire[`RegBus] opdata2_mult;	


assign excepttype_o = {excepttype_i[31:12],ovassert,trapassert,excepttype_i[9:8],8'h00};
assign is_in_delayslot_o = is_in_delayslot_i;
assign current_inst_address_o = current_inst_address_i;

// ** a variant of conflict type 1
wire[31:0]       reg1 = (mem_is_load_i && (mem_wd_i == reg1_addr_i) && reg1_is_imm==`IsNotImm) ? mem_wdata_i : reg1_i;
wire[31:0]       reg2 = (mem_is_load_i && (mem_wd_i == reg2_addr_i) && reg2_is_imm==`IsNotImm) ? mem_wdata_i : reg2_i;


assign aluop_o = aluop_i;
assign mem_addr_o = reg1 + {{16{inst_i[15]}},inst_i[15:0]};
assign reg2_o = reg2;

assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ? (~reg2_i)+1 : reg2_i); // for subtraction, convert the second input to ones's Complement 
assign is_load_o = aluop_i == `EXE_LB_OP || aluop_i == `EXE_LBU_OP || aluop_i == `EXE_LW_OP; // ** a very critical kind of conflict 1, needs an urgent stall

assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i; // for signed multiply, check the sign, if neg then OC, else nothing for signed operations
assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;		
assign hilo_temp = opdata1_mult * opdata2_mult;

wire[`RegBus]   sum_res = reg1 + reg2;
wire[`RegBus]   sub_res = reg1 + reg2_i_mux;

always @ * begin    // perform logical computation
    if (rst == `RstEnable) begin
        logic_res <= `ZeroWord;
    end else begin
        case (aluop_i)      // ** case various alu operations **

            `EXE_OR_OP: logic_res <= reg1 | reg2;

            `EXE_AND_OP: logic_res <= reg1 & reg2;
            
            `EXE_XOR_OP: logic_res <= reg1 ^ reg2;

            default: logic_res <= `ZeroWord;
            
        endcase
    end
end

always @ * begin    // perform shift computation
    if (rst == `RstEnable) begin
        shift_res <= `ZeroWord;
    end else begin
        case (aluop_i)      // ** case various alu operations **

            `EXE_SLL_OP: shift_res <= reg1 << reg2[4:0]; // shift less than 32 bits

            `EXE_SRL_OP: shift_res <= reg1 >> reg2[4:0];

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

            `EXE_SUB_OP, `EXE_SUBU_OP:	
				arith_res <= sub_res; 

            `EXE_CLZ_OP:  // count leading zeros in reg_1
                arith_res <= 
                    reg1[31]? 0  : reg1[30]? 1  : reg1[29]? 2  :
                    reg1[28]? 3  : reg1[27]? 4  : reg1[26]? 5  :
                    reg1[25]? 6  : reg1[24]? 7  : reg1[23]? 8  : 
                    reg1[22]? 9  : reg1[21]? 10 : reg1[20]? 11 :
                    reg1[19]? 12 : reg1[18]? 13 : reg1[17]? 14 : 
                    reg1[16]? 15 : reg1[15]? 16 : reg1[14]? 17 : 
                    reg1[13]? 18 : reg1[12]? 19 : reg1[11]? 20 :
                    reg1[10]? 21 : reg1[9]?  22 : reg1[8]?  23 : 
                    reg1[7]?  24 : reg1[6]?  25 : reg1[5]?  26 : 
                    reg1[4]?  27 : reg1[3]?  28 : reg1[2]?  29 : 
                    reg1[1]?  30 : reg1[0]?  31 : 32;

            default: arith_res <= `ZeroWord;
            
        endcase
    end
end

//***get the newest hi lo value from hi/lo (including for forwarding)***//
always @ (*) begin
		if(rst == `RstEnable) begin
			{HI,LO} <= {`ZeroWord,`ZeroWord};
		end else if(mem_whilo_i == `WriteEnable) begin
			{HI,LO} <= {mem_hi_i,mem_lo_i};
		end else if(wb_whilo_i == `WriteEnable) begin
			{HI,LO} <= {wb_hi_i,wb_lo_i};
		end else begin
			{HI,LO} <= {hi_i,lo_i};			
		end
	end	

//***MULTIPLICATION PROCESS***//																				
	always @ (*) begin
		if(rst == `RstEnable) begin
			mulres <= {`ZeroWord,`ZeroWord};
		end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP))begin
			if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin //XOR the signes of the inputs, if it is different, then mulres is the OC of hilo_temp, else do nothing just assign
				mulres <= ~hilo_temp + 1;
			end else begin
			    mulres <= hilo_temp;
			end
		end else begin
			    mulres <= hilo_temp; //if it is unsigned, then just assign
		end
	end
//***MULTIPLICATION PROCESS END***//

always @ (*) begin
        if(rst == `RstEnable) begin
            move_res <= `ZeroWord;
        end else begin
            move_res <= `ZeroWord;
                case (aluop_i)
                `EXE_MFHI_OP:		begin
                    move_res <= HI;
                end
                `EXE_MFLO_OP:		begin
                    move_res <= LO;
                end
                `EXE_MOVZ_OP:		begin
                    move_res <= reg1_i;
                end
                default : begin
            end
	    endcase
	end
end


always @ * begin    // perform moving

    if (rst == `RstEnable) begin
        cp0_reg_read_addr_o <= 0;
        move_res <= `ZeroWord;
    end else begin
        cp0_reg_read_addr_o <= 0;
        move_res <= `ZeroWord;
        case (aluop_i)

            `EXE_MOVZ_OP: move_res <= reg1;   // write or not is determined by wreg_o in id stage

            `EXE_MFC0_OP:		begin
	   	        cp0_reg_read_addr_o <= inst_i[15:11];
	   		    move_res <= cp0_reg_data_i;
                   //determined wheter the previous instruction in writing to the same
                   //reg as this instruction, which is reading, so consider it as forwarding
	   		        if( mem_cp0_reg_we == `WriteEnable &&
	   				    mem_cp0_reg_write_addr == inst_i[15:11] ) begin
	   				    move_res <= mem_cp0_reg_data;
	   		        end else if( wb_cp0_reg_we == `WriteEnable &&
	   				 	wb_cp0_reg_write_addr == inst_i[15:11] ) begin
	   				    move_res <= wb_cp0_reg_data;
                    end
                end

            default: move_res <= `ZeroWord;
            
        endcase
    end
end

always @ * begin    // perform loading
    if (rst == `RstEnable) begin
        load_res <= `ZeroWord;
    end else begin
        case (aluop_i)

            `EXE_LUI_OP: load_res <= reg1; // imm || 0^16

            `EXE_LB_OP, `EXE_LBU_OP, `EXE_LW_OP: load_res <= `ZeroWord; // wdata should be determined at mem stage

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

            `EXE_RES_MUL: wdata_o <= mulres[31:0];

            `EXE_RES_LOAD: wdata_o <= load_res;

            `EXE_RES_JUMP_BRANCH: wdata_o <= link_address_i;

            default: wdata_o <= `ZeroWord;

        endcase
    end
end

always @ (*) begin
    if(rst == `RstEnable) begin
        cp0_reg_write_addr_o <= 5'b00000;
        cp0_reg_we_o <= `WriteDisable;
        cp0_reg_data_o <= `ZeroWord;
    end else if(aluop_i == `EXE_MTC0_OP) begin
        cp0_reg_write_addr_o <= inst_i[15:11];
        cp0_reg_we_o <= `WriteEnable;
        cp0_reg_data_o <= reg1_i;
    end else begin
        cp0_reg_write_addr_o <= 5'b00000;
        cp0_reg_we_o <= `WriteDisable;
        cp0_reg_data_o <= `ZeroWord;
    end
end


always @ (*) begin
    if(rst == `RstEnable) begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;		
    end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin // assign hi lo(MUL operation wont be using hi/lo, only for mult and multu)
        whilo_o <= `WriteEnable;
        hi_o <= mulres[63:32];
        lo_o <= mulres[31:0];	
    end else begin
        whilo_o <= `WriteDisable;
        hi_o <= `ZeroWord;
        lo_o <= `ZeroWord;
    end
 end

 always @ (*) begin
		if(rst == `RstEnable) begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;		
		end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
			whilo_o <= `WriteEnable;
			hi_o <= mulres[63:32];
			lo_o <= mulres[31:0];			
		end else if(aluop_i == `EXE_MTHI_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= reg1_i;
			lo_o <= LO;
		end else if(aluop_i == `EXE_MTLO_OP) begin
			whilo_o <= `WriteEnable;
			hi_o <= HI;
			lo_o <= reg1_i;
		end else begin
			whilo_o <= `WriteDisable;
			hi_o <= `ZeroWord;
			lo_o <= `ZeroWord;
		end				
	end

// pipeline stalling demo:

always @* begin
    if (rst == `RstEnable)
        stallreq_o <= `StallDisable;
    else
        stallreq_o <= `StallDisable;
end


endmodule // ex