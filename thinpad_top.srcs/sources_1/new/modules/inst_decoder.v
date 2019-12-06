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
    input wire                  mem_is_load_i,

    // from ex
    input wire                  ex_wreg_i,
    input wire[`RegAddrBus]     ex_wd_i,
    input wire[`RegBus]         ex_wdata_i,
    input wire                  ex_is_load_i, // special conflict 1

     //from id_ex
    input wire                  is_in_delayslot_i,

	// to regfile
	output reg                  reg1_read_o,
	output reg                  reg2_read_o,

    // to regfile and to ex     
	output reg[`RegAddrBus]     reg1_addr_o,
	output reg[`RegAddrBus]     reg2_addr_o, 	      
	
	// to executor
	output reg[`AluOpBus]       aluop_o,
	output reg[`AluSelBus]      alusel_o,
	output reg[`RegBus]         reg1_o,  // value of num1
	output reg[`RegBus]         reg2_o,  // value of num2
	output reg                  wreg_o,  // write back or not?
	output reg[`RegAddrBus]     wd_o,  // addr of $rd
    output wire[`RegBus]        inst_o,

    // to ex
    output reg                  next_inst_in_delayslot_o,
    
    // to pc
    output reg                  branch_flag_o,
    output reg[`RegBus]         branch_target_address_o,

    // to ex
    output reg[`RegBus]         link_addr_o,
    output reg                  is_in_delayslot_o,

    output reg                  reg1_is_imm,
    output reg                  reg2_is_imm,

    output wire[31:0]           excepttype_o,
    output wire[`RegBus]        current_inst_address_o,

    // to ctrl
    output reg                  stallreq_o
);

assign inst_o = inst_i;


wire[5:0]       op  = inst_i[31:26];
wire[4:0]       op2 = inst_i[10:6];
wire[5:0]       op3 = inst_i[5:0];
wire[4:0]       op4 = inst_i[20:16];
wire[`RegBus]   pc_plus_8;
wire[`RegBus]   pc_plus_4;
wire[`RegBus]   imm_sll2_signedext;
reg[`RegBus]	imm;
reg instvalid;

reg excepttype_is_syscall;
reg excepttype_is_eret;

assign pc_plus_8 = pc_i + 8;
assign pc_plus_4 = pc_i + 4;
assign imm_sll2_signedext = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
assign inst_o = inst_i;

//stores the type of exception in this part and sends it to te next prt of mips.
assign excepttype_o = {19'b0, excepttype_is_eret, 2'b0, instvalid, excepttype_is_syscall, 8'b0};

assign current_inst_address_o = pc_i;

// decode from inst, to ex
always @ (*) begin

    excepttype_is_syscall <= `False_v;	
	excepttype_is_eret <= `False_v;	

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

        link_addr_o <= `ZeroWord;
        branch_target_address_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;

        reg1_is_imm <= `IsNotImm;
        reg2_is_imm <= `IsNotImm;
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
        link_addr_o <= `ZeroWord;
        branch_target_address_o <= `ZeroWord;
        branch_flag_o <= `NotBranch;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
        reg1_is_imm <= `IsNotImm;
        reg2_is_imm <= `IsNotImm;
        
        if(inst_i == `ZeroWord) begin
            instvalid <= `InstValid;
        end else case (op)
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

                        `EXE_ADDU, `EXE_ADD: begin
                            aluop_o <= `EXE_ADDU_OP;
                            alusel_o <= `EXE_RES_ARITH;
                            reg1_read_o <= `ReadEnable;  // $rs
                            reg2_read_o <= `ReadEnable;  // $rt
                            wreg_o <= `WriteEnable;
                            wd_o <= inst_i[15:11];       // $rd
                            instvalid <= `InstValid;
                        end
                        
                        `EXE_SUB, `EXE_SUBU: begin
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_SUBU_OP;
                            alusel_o <= `EXE_RES_ARITH;		
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1;
                            instvalid <= `InstValid;	
                        end

                        `EXE_MULT: begin
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MULT_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
						end

						`EXE_MULTU: begin
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MULTU_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
						end

                        `EXE_DIV: begin
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_DIV_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
						end

                        `EXE_DIVU: begin
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_DIVU_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b1; 
                            instvalid <= `InstValid;	
                        end

                        `EXE_MFHI: begin
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_MFHI_OP;
                            alusel_o <= `EXE_RES_MOVE;  
                            reg1_read_o <= 1'b0;	
                            reg2_read_o <= 1'b0;
                            instvalid <= `InstValid;	
						end

                        `EXE_MFLO: begin
                            wreg_o <= `WriteEnable;		
                            aluop_o <= `EXE_MFLO_OP;
                            alusel_o <= `EXE_RES_MOVE;   
                            reg1_read_o <= 1'b0;	
                            reg2_read_o <= 1'b0;
                            instvalid <= `InstValid;	
                        end

                        `EXE_MTHI: begin
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MTHI_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0; 
                            instvalid <= `InstValid;	
                        end

                        `EXE_MTLO: begin
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_MTLO_OP;
                            reg1_read_o <= 1'b1;	
                            reg2_read_o <= 1'b0; 
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

                        `EXE_JR: begin
                            wreg_o <= `WriteDisable;
                            aluop_o <= `EXE_JR_OP;
                            alusel_o <= `EXE_RES_JUMP_BRANCH;
                            reg1_read_o <= `ReadEnable;
                            reg2_read_o <= `ReadDisable;
                            reg2_is_imm <=`IsImm;
                            link_addr_o <= `ZeroWord;
                            branch_target_address_o <= reg1_o;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;
                            instvalid <= `InstValid;
                        end
                        `EXE_SYSCALL: begin
                            $display("id: syscall");
                            wreg_o <= `WriteDisable;		
                            aluop_o <= `EXE_SYSCALL_OP;
                            alusel_o <= `EXE_RES_NOP;  
                            reg1_read_o <= 1'b0;	
                            reg2_read_o <= 1'b0;
                            instvalid <= `InstValid; 
                            excepttype_is_syscall<= `True_v;
                        end	
                        default: $display("unknown op3!");
                    endcase 

                else if (inst_i[25:21] == 5'b00000)
                    case (op3)
                         `EXE_SLL: begin // be careful!
                            aluop_o <= `EXE_SLL_OP;
                            alusel_o <= `EXE_RES_SHIFT;
                            reg1_read_o <= `ReadEnable;  // $rt
                            reg1_addr_o <= inst_i[20:16];
                            reg2_read_o <= `ReadDisable; // sa
                            reg2_is_imm <=`IsImm;
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
                            reg2_is_imm <=`IsImm;
                            imm[4:0] <= inst_i[10:6];
                            wreg_o <= `WriteEnable;
                            wd_o <= inst_i[15:11];
                            instvalid <= `InstValid;
                        end

                        default: $display("unknown op3!"); 
                    endcase

                else
                    $display("unknown EXE_SPECIAL!");
            // EXE_SPECIAL

            `EXE_SPECIAL2:
                if (op2 == 5'b00000 && op3 == `EXE_CLZ) begin
                    aluop_o <= `EXE_CLZ_OP;
                    alusel_o <= `EXE_RES_ARITH;
                    reg1_read_o <= `ReadEnable;  // $rs
                    reg2_read_o <= `ReadDisable;
                    reg2_is_imm <=`IsImm;
                    wreg_o <= `WriteEnable;
                    wd_o <= inst_i[15:11];  // $rd
                    instvalid <= `InstValid;
                end else if(op2 == 5'b00000 && op3 == `EXE_MUL)begin
                    wreg_o <= `WriteEnable;		
                    aluop_o <= `EXE_MUL_OP;
		  			alusel_o <= `EXE_RES_MUL; 
                    reg1_read_o <= 1'b1;	
                    reg2_read_o <= 1'b1;	
		  			instvalid <= `InstValid;
                end else $display("unknown EXE_SPECIAL2!");
                
            `EXE_ORI: begin     // ori $rd, $rs, imm
                aluop_o <= `EXE_OR_OP;
                alusel_o <= `EXE_RES_LOGIC;
                reg1_read_o <= `ReadEnable;     // enable reading from regfile, to regfile
                reg2_read_o <= `ReadDisable;	// disable readding (filled by imm)
                reg2_is_imm <=`IsImm;
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
                reg2_is_imm <=`IsImm;
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
                reg2_is_imm <=`IsImm;
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
                reg2_is_imm <=`IsImm;
                imm <= {{16{inst_i[15]}}, inst_i[15:0]}; // * caution: ADDIU applies signed extending!
                wreg_o <= `WriteEnable;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_LUI: if (inst_i[25:21] == 5'b00000) begin
                aluop_o <= `EXE_LUI_OP;
                alusel_o <= `EXE_RES_LOAD;
                reg1_read_o <= `ReadDisable;  // imm
                reg1_is_imm <=`IsImm;
                imm <= {inst_i[15:0], 16'b0}; // zero extend at tail
                reg2_read_o <= `ReadDisable;
                reg2_is_imm <=`IsImm;
                wreg_o <= `WriteEnable;  // $rt
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end else $display("unknown!");
            
            `EXE_J: begin
		  		wreg_o <= `WriteDisable;
                aluop_o <= `EXE_J_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
		  		link_addr_o <= `ZeroWord;
			    branch_flag_o <= `Branch;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    instvalid <= `InstValid;
                branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			end

            `EXE_JAL: begin
		  		wreg_o <= `WriteEnable;
                aluop_o <= `EXE_JAL_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
		  		wd_o <= 5'b11111;	
		  		link_addr_o <= pc_plus_8 ;
                branch_flag_o <= `Branch;
                next_inst_in_delayslot_o <= `InDelaySlot;
                instvalid <= `InstValid;
			    branch_target_address_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
			end

            `EXE_BEQ:begin
		  		wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BEQ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
		  		instvalid <= `InstValid;	
		  		if(reg1_o == reg2_o) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    	next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
            end

            `EXE_BGTZ:begin
		  		wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BGTZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
		  		instvalid <= `InstValid;	
		  		if((reg1_o[31] == 1'b0) && (reg1_o != `ZeroWord)) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    	next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
			end

            `EXE_BLEZ:begin
		  		wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BLEZ_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
		  		instvalid <= `InstValid;	
		  		if((reg1_o[31] == 1'b1) || (reg1_o == `ZeroWord)) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    	next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
			end

            `EXE_BNE:begin
		  		wreg_o <= `WriteDisable;
                aluop_o <= `EXE_BNE_OP;
		  		alusel_o <= `EXE_RES_JUMP_BRANCH;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadEnable;
		  		instvalid <= `InstValid;	
		  		if(reg1_o != reg2_o) begin
			    	branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
			    	branch_flag_o <= `Branch;
			    	next_inst_in_delayslot_o <= `InDelaySlot;		  	
			    end
            end

            `EXE_REGIMM_INST: begin
                case (op4)
                    `EXE_BGEZ: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BGEZ_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instvalid <= `InstValid;	
                        if(reg1_o[31] == 1'b0) begin
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;		  	
                        end
                    end

                    `EXE_BLTZ: begin
                        wreg_o <= `WriteDisable;
                        aluop_o <= `EXE_BLTZ_OP;
                        alusel_o <= `EXE_RES_JUMP_BRANCH;
                        reg1_read_o <= `ReadEnable;
                        reg2_read_o <= `ReadDisable;
                        instvalid <= `InstValid;	
                        if(reg1_o[31] == 1'b1) begin
                            branch_target_address_o <= pc_plus_4 + imm_sll2_signedext;
                            branch_flag_o <= `Branch;
                            next_inst_in_delayslot_o <= `InDelaySlot;		  	
                        end
                    end
                    default: $display("unknown op4 0x%x", op4);
                endcase
            end

            `EXE_LB:begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LB_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadEnable;
                reg2_read_o <= `ReadDisable;
                reg2_is_imm <=`IsImm;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_LBU:begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LBU_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_LWPC:begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LWPC_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= `ReadDisable;
                reg2_read_o <= `ReadDisable;
                wd_o <= inst_i[25:21];
                instvalid <= `InstValid;
            end

            `EXE_LW:begin
                wreg_o <= `WriteEnable;
                aluop_o <= `EXE_LW_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b0;
                wd_o <= inst_i[20:16];
                instvalid <= `InstValid;
            end

            `EXE_SW:begin
                wreg_o <= `WriteDisable;
                aluop_o <= `EXE_SW_OP;
                alusel_o <= `EXE_RES_LOAD_STORE;
                reg1_read_o <= 1'b1;
                reg2_read_o <= 1'b1;
                instvalid <= `InstValid;
            end

            `EXE_SB:begin
                wreg_o <= `WriteDisable;
                aluop_o <=`EXE_SB_OP;
                reg1_read_o <=1'b1;
                reg2_read_o <= 1'b1;
                instvalid <= `InstValid;
                alusel_o <= `EXE_RES_LOAD_STORE;
            end

            default: begin
                if(inst_i == `EXE_ERET) begin
                    wreg_o <= `WriteDisable;		
                    aluop_o <= `EXE_ERET_OP;
                    alusel_o <= `EXE_RES_NOP;  
                    reg1_read_o <= 1'b0;	
                    reg2_read_o <= 1'b0;
                    instvalid <= `InstValid; 
                    excepttype_is_eret<= `True_v;				
                end else if (inst_i[31:21] == 11'b01000000000 && inst_i[10:1] == 10'b0000000000) begin //MFC0 OP
                    // $display("id: mfc0");
                    aluop_o <= `EXE_MFC0_OP;
                    alusel_o <= `EXE_RES_MOVE;
                    wd_o <= inst_i[20:16];
                    wreg_o <= `WriteEnable;
                    instvalid <= `InstValid;	   
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;		
                end else if(inst_i[31:21] == 11'b01000000100 && inst_i[10:1] == 10'b0000000000) begin //MTC0 OP
                    // $display("id: mtc0");
                    aluop_o <= `EXE_MTC0_OP;
                    alusel_o <= `EXE_RES_NOP;
                    wreg_o <= `WriteDisable;
                    instvalid <= `InstValid;	   
                    reg1_read_o <= 1'b1;
                    reg1_addr_o <= inst_i[20:16];
                    reg2_read_o <= 1'b0;					
                end else $display("error in id: invalid inst!");
            end

        endcase // op

    end       // if

end         // always


// from regfile, to id-ex
always @ (*) begin

    stallreq_o <= `StallDisable;
    
    // reg1
    if (rst == `RstEnable) begin
        reg1_o <= `ZeroWord;
    end else if (reg1_read_o == `ReadEnable) begin

        if (ex_wreg_i == `WriteEnable && reg1_addr_o == ex_wd_i) begin // ** conflict type 1 (PRIOR to type 2)
            if (ex_is_load_i) begin
                stallreq_o <= `StallEnable; // critical conflict type 1, wait 2 clks
                reg1_o <= `ZeroWord;
            end else
                reg1_o <= ex_wdata_i;

        end else if (mem_wreg_i == `WriteEnable && reg1_addr_o == mem_wd_i) begin // ** conflict type 2
            if (mem_is_load_i) begin // mem is loading, wait 1 clk
                stallreq_o <= `StallEnable;
                reg1_o <= `ZeroWord;
            end else
                reg1_o <= mem_wdata_i;

        end else
            reg1_o <= reg1_data_i;

    end else if (reg1_read_o == `ReadDisable) begin
        reg1_o <= imm;
    end else begin      // ???
        reg1_o <= `ZeroWord;
    end

    // reg2
    if (rst == `RstEnable) begin
        reg2_o <= `ZeroWord;
    end else if (reg2_read_o == `ReadEnable) begin

        if (ex_wreg_i == `WriteEnable && reg2_addr_o == ex_wd_i) begin // ** conflict type 1 (PRIOR to type 2)
            if (ex_is_load_i) begin
                stallreq_o <= `StallEnable; // critical conflict type 1, wait 2 clks
                reg2_o <= `ZeroWord;
            end else
                reg2_o <= ex_wdata_i;

        end else if (mem_wreg_i == `WriteEnable && reg2_addr_o == mem_wd_i) begin // ** conflict type 2
            if (mem_is_load_i) begin // mem is loading, wait 1 clk
                stallreq_o <= `StallEnable;
                reg2_o <= `ZeroWord;
            end else
                reg2_o <= mem_wdata_i;
                
        end else
            reg2_o <= reg2_data_i;

    end else if (reg2_read_o == `ReadDisable) begin
        reg2_o <= imm;
    end else begin      // ???
        reg2_o <= `ZeroWord;
    end

end


always @ (*) begin
    if(rst == `RstEnable) begin
        is_in_delayslot_o <= `NotInDelaySlot;
    end else begin
        is_in_delayslot_o <= is_in_delayslot_i;		
    end
end

endmodule