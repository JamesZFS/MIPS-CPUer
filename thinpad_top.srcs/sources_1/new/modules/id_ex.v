
module id_ex(
	input	wire  clk,
	input   wire  rst,
	
	// signal from id
	input wire[`AluOpBus]         id_aluop,
	input wire[`AluSelBus]        id_alusel,
	input wire[`RegBus]           id_reg1,
	input wire[`RegBus]           id_reg2,
	input wire[`RegAddrBus]       id_wd,
	input wire[`RegBus]			  id_link_address,
	input wire					  id_is_in_delayslot,
	input wire					  next_inst_in_delayslot_i,
	input wire                    id_wreg,	
	input wire[`RegBus]			  id_inst,
	input wire[`RegAddrBus]       id_reg1_addr,
	input wire[`RegAddrBus]       id_reg2_addr, 
	input wire 					  id_reg1_is_imm,
	input wire 					  id_reg2_is_imm,


	input wire[0:5]               stall, // from ctrl
	
	// signal to ex
	output reg[`AluOpBus]         ex_aluop,
	output reg[`AluSelBus]        ex_alusel,
	output reg[`RegBus]           ex_reg1,
	output reg[`RegBus]           ex_reg2,
	output reg[`RegAddrBus]       ex_wd,
	output reg[`RegBus]			  ex_link_address,
	output reg					  ex_is_in_delayslot,
	output reg                    ex_wreg,
	output reg[`RegBus]			  ex_inst,
	output reg[`RegAddrBus]       ex_reg1_addr,
	output reg[`RegAddrBus]       ex_reg2_addr, 
	output reg 					  ex_reg1_is_imm,
	output reg 					  ex_reg2_is_imm,
	
	// to id
	output reg					  is_in_delayslot_o // forward
);

always @ (posedge clk) begin
    if (rst == `RstEnable || (stall[2] == `StallEnable && stall[3] == `StallDisable)) begin
		// reset or ** at the tail of a stall sequence
        ex_aluop  <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1   <= `ZeroWord;
        ex_reg2   <= `ZeroWord;
        ex_wd     <= `NOPRegAddr;
        ex_wreg   <= `WriteDisable;
		ex_link_address <= `ZeroWord;
		ex_is_in_delayslot <= `NotInDelaySlot;
		is_in_delayslot_o <= `NotInDelaySlot;
		ex_inst <= `ZeroWord; 
		ex_reg1_addr <= `NOPRegAddr;
		ex_reg2_addr <= `NOPRegAddr;
		ex_reg1_is_imm <= `IsNotImm;
		ex_reg2_is_imm <= `IsNotImm;
    end else if (stall[2] == `StallDisable) begin
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
		ex_link_address <= id_link_address;
		ex_is_in_delayslot <= id_is_in_delayslot;
		is_in_delayslot_o <= next_inst_in_delayslot_i;
		ex_inst <= id_inst;
		ex_reg2_addr <= id_reg2_addr;
		ex_reg1_addr <= id_reg1_addr;
		ex_reg1_is_imm <= id_reg1_is_imm;
		ex_reg2_is_imm <= id_reg2_is_imm;
    end // else: hold on
end
	
endmodule