module mem(
    input wire      rst,

    // singals from ex
    input wire                    wreg_i,
    input wire[`RegAddrBus]       wd_i,
    input wire[`RegBus]           wdata_i,

    input wire[`AluOpBus]         aluop_i,
    input wire[`RegBus]           mem_addr_i,
    input wire[`RegBus]           reg2_i,
    input wire                    cp0_reg_we_i,
	input wire[4:0]               cp0_reg_write_addr_i,
	input wire[`RegBus]           cp0_reg_data_i,

    input wire[31:0]             excepttype_i,
	input wire                   is_in_delayslot_i,
	input wire[`RegBus]          current_inst_address_i,	

    //from cp0
    input wire[`RegBus]          cp0_status_i,
	input wire[`RegBus]          cp0_cause_i,
	input wire[`RegBus]          cp0_epc_i,

    input wire                    wb_cp0_reg_we,
	input wire[4:0]               wb_cp0_reg_write_addr,
	input wire[`RegBus]           wb_cp0_reg_data,

    // signals to wb (and forward to id)
    output reg                    wreg_o,
    output reg[`RegAddrBus]       wd_o,
    output reg[`RegBus]           wdata_o,
    output reg                    wstate_o,  // to mem/wb and then to mem itself
    input  wire                   wstate_i,  // from mem/wb to itself

    //signal to MMU
    output reg[`RegBus]           mem_addr_o,
    output reg                    mem_we_o,
    output reg[`RegBus]           mem_data_o,
    output wire                   mem_ce_o,
    output reg[3:0]               mem_sel_o,

    // forward to ex
    output wire                   is_load_o,

    //signal from mmu
    input wire[`RegBus]           mem_data_i,

    // from cp0
    output reg                    cp0_reg_we_o,
	output reg[4:0]               cp0_reg_write_addr_o,
	output reg[`RegBus]           cp0_reg_data_o,

    output reg[31:0]              excepttype_o,
	output wire[`RegBus]          cp0_epc_o,
	output wire                   is_in_delayslot_o,
    output wire[`RegBus]          current_inst_address_o,

    output reg                    stallreq_o  // to ctrl
);

reg mem_ce;

assign is_load_o = aluop_i == `EXE_LB_OP || aluop_i == `EXE_LBU_OP || aluop_i == `EXE_LW_OP;


reg[`RegBus]          cp0_status;
reg[`RegBus]          cp0_cause;
reg[`RegBus]          cp0_epc;	

assign is_in_delayslot_o = is_in_delayslot_i;
assign current_inst_address_o = current_inst_address_i;
assign cp0_epc_o = cp0_epc;

//if an exception occurs, then cancel the r/w action for the mem
assign mem_ce_o = mem_ce & (~(|excepttype_o));


always @* begin
    if (rst == `RstEnable) begin
        wreg_o  <= `WriteDisable;
        wd_o    <= `NOPRegAddr;
        wdata_o <= `ZeroWord;
        wstate_o <= 0;

        mem_addr_o <= `ZeroWord;
        mem_we_o <= `WriteDisable;
        mem_sel_o <= 4'b0000;
        mem_data_o <= `ZeroWord;
        mem_ce <= `ChipDisable;

        cp0_reg_we_o <= `WriteDisable;
		cp0_reg_write_addr_o <= 5'b00000;
		cp0_reg_data_o <= `ZeroWord;

        stallreq_o <= `StallDisable;

    end else begin
        wreg_o  <= wreg_i;
        wd_o    <= wd_i;
        wdata_o <= wdata_i;
        wstate_o <= 0;

        cp0_reg_we_o <= cp0_reg_we_i;
		cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
		cp0_reg_data_o <= cp0_reg_data_i;

        mem_addr_o <= `ZeroWord;
        mem_we_o <= `WriteDisable;
        mem_sel_o <= 4'b0000;
        mem_data_o <= `ZeroWord;
        mem_ce <= `ChipDisable;

        stallreq_o <= `StallDisable;

        case (aluop_i)
            `EXE_LB_OP: begin
                mem_addr_o <= mem_addr_i;
                mem_we_o <= `WriteDisable;
                mem_ce <= `ChipEnable;
                case (mem_addr_i[1:0])  // TODO endian!
                    2'b00: begin
                        wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                        // mem_sel_o <= 4'b0001;
                    end
                    2'b01: begin
                        wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                        // mem_sel_o <= 4'b0010;
                    end
                    2'b10: begin
                        wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                        // mem_sel_o <= 4'b0100;
                    end
                    2'b11: begin
                        wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                        // mem_sel_o <= 4'b1000;
                    end
                endcase
            end
            `EXE_LBU_OP: begin
                mem_addr_o <= mem_addr_i;
                mem_we_o <= `WriteDisable;
                mem_ce<=`ChipEnable;
                case(mem_addr_i[1:0])
                    2'b00: begin        //TODO endian
                        wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
                        // mem_sel_o <= 4'b0001;
                    end
                    2'b01: begin
                        wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
                        // mem_sel_o <= 4'b0010;
                    end
                    2'b10: begin
                        wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
                        // mem_sel_o <= 4'b0100;
                    end
                    2'b11: begin 
                        wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
                        // mem_sel_o <= 4'b1000;
                    end
                endcase
            end

            `EXE_LW_OP: begin
                mem_addr_o <= mem_addr_i;
                mem_we_o <= `WriteDisable;
                wdata_o <= mem_data_i;
                // mem_sel_o <= 4'b0000;
                mem_ce <= `ChipEnable;
            end

            `EXE_SW_OP: begin
                case (wstate_i)   // write mem stage FSM
                    0: begin 
                        wstate_o <= 1;
                        stallreq_o <= `StallEnable;
                    end
                    1: begin 
                        wstate_o <= 0;
                        stallreq_o <= `StallDisable;
                    end
                endcase
                mem_addr_o <= mem_addr_i;
                mem_we_o <= `WriteEnable;
                mem_ce <= `ChipEnable;
                mem_data_o <= reg2_i;
                // mem_sel_o <= 4'b0000;
            end

            `EXE_SB_OP:begin
                case (wstate_i)   // write mem stage FSM
                    0: begin 
                        wstate_o <= 1;
                        stallreq_o <= `StallEnable;
                    end
                    1: begin 
                        wstate_o <= 0;
                        stallreq_o <= `StallDisable;
                    end
                endcase
                mem_addr_o <= mem_addr_i;
                mem_we_o <= `WriteEnable;
                mem_ce <= `ChipEnable;
                mem_data_o <= {32{reg2_i[7:0]}};
                case(mem_addr_i[1:0])
                    2'b00: begin
                        mem_sel_o <= 4'b1110;
                    end
                    2'b01: begin 
                        mem_sel_o <= 4'b1101;
                    end
                    2'b10: begin
                        mem_sel_o <= 4'b1011;
                    end
                    2'b11: begin
                        mem_sel_o <= 4'b0111;
                    end
                endcase
            end

            default: ;
        endcase
    end
end

//the below few "always" determines if it is write or read the newest value from cp0
always @ (*) begin
    if(rst == `RstEnable) begin
        cp0_status <= `ZeroWord;
    end else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_STATUS ))begin
        cp0_status <= wb_cp0_reg_data;
    end else begin
        cp0_status <= cp0_status_i;
    end
end
	
always @ (*) begin
    if(rst == `RstEnable) begin
        cp0_epc <= `ZeroWord;
    end else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_EPC ))begin
        cp0_epc <= wb_cp0_reg_data;
    end else begin
        cp0_epc <= cp0_epc_i;
    end
end

always @ (*) begin
    if(rst == `RstEnable) begin
        cp0_cause <= `ZeroWord;
    end else if((wb_cp0_reg_we == `WriteEnable) && (wb_cp0_reg_write_addr == `CP0_REG_CAUSE ))begin
        //only ip[1:0], iv, and wp is writeable (for more information please read page 298 in the CPU book)
        cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
        cp0_cause[22] <= wb_cp0_reg_data[22];
        cp0_cause[23] <= wb_cp0_reg_data[23];
    end else begin
        cp0_cause <= cp0_cause_i;
    end
end

always @ (*) begin
    if(rst == `RstEnable) begin
        excepttype_o <= `ZeroWord;
    end else begin
        if(current_inst_address_i != `ZeroWord) begin
            // if (((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin
            if (cp0_status[1:0] == 2'b01 && cp0_cause[10] == 1'b1) begin // if enable interrupt and not in exception state and exists uart interrupt, see P290
                $display("raise IRQ exception!");
                excepttype_o <= 32'h00000001;        //hardware interrupt
            end else if(excepttype_i[8] == 1'b1) begin
                excepttype_o <= 32'h00000008;        //syscall
            end else if(excepttype_i[9] == 1'b1) begin
                excepttype_o <= 32'h0000000a;        //inst_invalid (***a very weird bug occured, have to communicate with zfs***)
            end else if(excepttype_i[11] == 1'b1) begin 
                excepttype_o <= 32'h0000000c;        //over  
            end else if(excepttype_i[12] == 1'b1) begin  
                excepttype_o <= 32'h0000000e;       //eret
            end else begin
                excepttype_o <= 32'h00000000;  // default type must be zero!!
            end
        end	else begin
            excepttype_o <= `ZeroWord;
        end
        
    end
end


endmodule // mem
