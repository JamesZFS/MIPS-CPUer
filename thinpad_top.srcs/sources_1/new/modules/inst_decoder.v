module id(
	input wire					rst, // no clk, a combination logic

    // from if
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
	output reg[`RegAddrBus]     wd_o,  // addr of $rd

    // to ctrl
    output reg                  stallreq_o
);

wire[5:0]       op  = inst_i[31:26];
wire[4:0]       op2 = inst_i[10:6];
wire[5:0]       op3 = inst_i[5:0];
wire[4:0]       op4 = inst_i[20:16];
reg[`RegBus]	imm;
reg instvalid;

// decode from inst, to ex
always @ (*) begin

    if (rst == `RstEnable) begin

        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wreg_o <= `WriteDisable;
        wd_o <= `NOPRegAddr;
        instvalid <= `InstValid;
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= `ZeroWord;

    end else begin

        // default signals:
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wreg_o <= `WriteDisable;
        wd_o <= inst_i[15:11];
        instvalid <= `InstInvalid;
        reg1_read_o <= `ReadDisable;
        reg2_read_o <= `ReadDisable;
        reg1_addr_o <= inst_i[25:21];
        reg2_addr_o <= inst_i[20:16];
        imm <= `ZeroWord;

        case (op)

            `EXE_SPECIAL:
                if (op2 == 5'b00000)
                    case (op3)

                        `EXE_OR: begin
                            aluop_o <= `EXE_OR_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            wreg_o <= `WriteEnable;
                            wd_o <= inst_i[15:11];
                            instvalid <= `InstValid;
                        end

                        `EXE_AND: begin
                            aluop_o <= `EXE_AND_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            wreg_o <= `WriteEnable;
                            wd_o <= inst_i[15:11];
                            instvalid <= `InstValid;
                        end

                        `EXE_XOR: begin
                            aluop_o <= `EXE_XOR_OP;
                            alusel_o <= `EXE_RES_LOGIC;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadEnable;
                            wreg_o <= `WriteEnable;
                            wd_o <= inst_i[15:11];
                            instvalid <= `InstValid;
                        end

                        `EXE_ADDU: begin
                            aluop_o <= `EXE_ADDU_OP;
                            alusel_o <= `EXE_RES_ARITH;
                            reg1_read_o <= `ReadEnable;  // $rs
                            reg2_read_o <= `ReadEnable;  // $rt
                            wreg_o <= `WriteEnable;
                            wd_o <= inst_i[15:11];       // $rd
                            instvalid <= `InstValid;
                        end

                        `EXE_MOVZ: begin
                            aluop_o <= `EXE_MOVZ_OP;
                            alusel_o <= `EXE_RES_MOVE;
                            reg1_read_o <= `ReadEnable;  // $rs
                            reg2_read_o <= `ReadEnable;  // $rt
                            // ** determine whether to wb or not 
                            // (notice $rt is using the newest value reg2_o instead of reg2_data_i)
                            wreg_o <= reg2_o == `ZeroWord ? `WriteEnable : `WriteDisable;
                            wd_o <= inst_i[15:11];       // $rd
                            instvalid <= `InstValid;
                        end

                        default: ;
                    endcase 

                else if (inst_i[25:21] == 5'b00000)
                    case (op3)
                         `EXE_SLL: begin // be careful!
                            aluop_o <= `EXE_SLL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            reg1_read_o <= `ReadEnable;  // $rt
                            reg1_addr_o <= inst_i[20:16];
                            reg2_read_o <= `ReadDisable; // sa
                            imm[4:0] <= inst_i[10:6];
                            wreg_o <= `WriteEnable;
                            wd_o <= inst_i[15:11];
                            instvalid <= `InstValid;
                        end

                        `EXE_SRL: begin
                            aluop_o <= `EXE_SRL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            reg1_read_o <= `ReadEnable;  // $rt
                            reg1_addr_o <= inst_i[20:16];
                            reg2_read_o <= `ReadDisable; // sa
                            imm[4:0] <= inst_i[10:6];
                            wreg_o <= `WriteEnable;
                            wd_o <= inst_i[15:11];
                            instvalid <= `InstValid;
                        end

                        default: ; 
                    endcase
                // else: unknown
            // EXE_SPECIAL

            `EXE_SPECIAL2:
                if (op2 == 5'b00000 && op3 == `EXE_CLZ) begin
                    aluop_o <= `EXE_CLZ_OP;
                    alusel_o <= `EXE_RES_ARITH;
                    reg1_read_o <= `ReadEnable;  // $rs
                    reg2_read_o <= `ReadDisable;
                    wreg_o <= `WriteEnable;
                    wd_o <= inst_i[15:11];  // $rd
                    instvalid <= `InstValid;
                end
                // else: unknown
                
            `EXE_ORI: begin     // ori $rd, $rs, imm
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;     // enable reading from regfile, to regfile
                reg2_read_o <= `ReadDisable;	// disable readding (filled by imm)
                imm <= {16'h0, inst_i[15:0]};   // zero extend at front
                wreg_o <= `WriteEnable;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_ANDI: begin
                aluop_o <= `EXE_AND_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wreg_o <= `WriteEnable;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_XORI: begin
                aluop_o <= `EXE_XOR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wreg_o <= `WriteEnable;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_ADDIU: begin
                aluop_o <= `EXE_ADDU_OP;
                alusel_o <= `EXE_RES_ARITH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                imm <= {16'h0, inst_i[15:0]};
                wreg_o <= `WriteEnable;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_LUI: if (inst_i[25:21] == 5'b00000) begin
                aluop_o <= `EXE_LUI_OP;
                alusel_o <= `EXE_RES_LOAD;
                reg1_read_o <= `ReadDisable;  // imm
                imm <= {inst_i[15:0], 16'b0}; // zero extend at tail
                reg2_read_o <= `ReadDisable;
                wreg_o <= `WriteEnable;  // $rt
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end // else: unknown

            default: ;

        endcase // op

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
            reg2_o <= reg2_data_i;
        end

    end else if (reg2_read_o == `ReadDisable) begin
        reg2_o <= imm;
    end else begin      // ???
        reg2_o <= `ZeroWord;
    end

end

endmodule