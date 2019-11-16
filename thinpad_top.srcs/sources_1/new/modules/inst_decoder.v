module id(
	input wire					rst, // no clk, a combination logic
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstBus]        inst_i,

    // from regfile
	input wire[`RegBus]         reg1_data_i,
	input wire[`RegBus]         reg2_data_i,

    // from mem
    input wire                  mem_wreg_i,
    input wire[`RegAddrBus]     mem_wd_i,  // which reg may be conflicting?
    input wire[`RegBus]         mem_wdata_i,

    // from ex
    input wire                  ex_wreg_i,
    input wire[`RegAddrBus]     ex_wd_i,
    input wire[`RegBus]         ex_wdata_i,

	// to regfile
	output reg                  reg1_read_o,
	output reg                  reg2_read_o,     
	output reg[`RegAddrBus]     reg1_addr_o,
	output reg[`RegAddrBus]     reg2_addr_o, 	      
	
	// to executor
	output reg[`AluOpBus]       aluop_o,
	output reg[`AluSelBus]      alusel_o,
	output reg[`RegBus]         reg1_o,  // value of num1
	output reg[`RegBus]         reg2_o,  // value of num2
	output reg                  wreg_o,  // write back or not?
	output reg[`RegAddrBus]     wd_o  // addr of $rd
);

wire[5:0]       op  = inst_i[31:26];
wire[4:0]       op2 = inst_i[10:6];
wire[5:0]       op3 = inst_i[5:0];
wire[4:0]       op4 = inst_i[20:16];
reg[`RegBus]	imm;
reg instvalid;


always @ (*) begin

    if (rst == `RstEnable) begin

        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        instvalid <= `InstValid;
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= `ZeroWord;

    end else begin

        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wd_o <= inst_i[15:11];
        wreg_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= inst_i[25:21];
        reg2_addr_o <= inst_i[20:16];
        imm <= `ZeroWord;

        case (op)

            `EXE_ORI: begin                        // `ori` inst
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;     // enable reading from regfile, to regfile
                reg2_read_o <= `ReadDisable;	// disable readding (filled by imm)
                imm <= {16'h0, inst_i[15:0]};   // zero extend at front
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end 		

            default: ;

        endcase

    end       // if

end         // always

// from regfile, to id-ex
always @ (*) begin

    if(rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if (reg1_read_o == `ReadEnable) begin

        if (ex_wreg_i == `WriteEnable && reg1_addr_o == ex_wd_i) begin // ** conflict type 1 (PRIOR to type 2)
            reg1_o <= ex_wdata_i;
        end else if (mem_wreg_i == `WriteEnable && reg1_addr_o == mem_wd_i) begin // ** conflict type 2
            reg1_o <= mem_wdata_i;
        end else begin
            reg1_o <= reg1_data_i;
        end

    end else if (reg1_read_o == `ReadDisable) begin
        reg1_o <= imm;
    end else begin      // ???
        reg1_o <= `ZeroWord;
    end

end

always @ (*) begin

    if(rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if (reg2_read_o == `ReadEnable) begin

        if (ex_wreg_i == `WriteEnable && reg2_addr_o == ex_wd_i) begin // ** conflict type 1 (PRIOR to type 2)
            reg2_o <= ex_wdata_i;
        end else if (mem_wreg_i == `WriteEnable && reg2_addr_o == mem_wd_i) begin // ** conflict type 2
            reg2_o <= mem_wdata_i;
        end else begin
            reg2_o <= reg1_data_i;
        end

    end else if (reg2_read_o == `ReadDisable) begin
        reg2_o <= imm;
    end else begin      // ???
        reg2_o <= `ZeroWord;
    end

end

endmodule