module mips(
    input wire      clk,
    input wire      rst,

    // from mmu
    input wire[31:0]         mmu_mem_data_i,
    input wire[31:0]         ram_inst_i,    // instruction input
    input wire               mmu_stallreq_i, // to ctrl
    input wire               uart_int_i, // to mem
    
    // if-id to mmu
    output wire[`InstAddrBus]    ram_addr_o,
    output wire                  ram_ce_o,

    // mem to mmu
    output wire[`RegBus]         mem_addr_o,
    output wire                  mem_we_o,
    output wire[`RegBus]         mem_data_o,
    output wire                  mem_ce_o,
    output wire[3:0]             mem_sel_o,

    // mem/wb to mmu
    output wire                  wstate_o,

    output wire[`RegBus]         debug1_o,        // signal for debug display
    output wire[`RegBus]         debug2_o        // signal for debug display
);

wire[`InstAddrBus] pc;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;

// id --> id/ex
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegBus] id_reg1_o;
wire[`RegBus] id_reg2_o;
wire id_wreg_o;
wire[`RegAddrBus] id_wd_o;
wire[`RegBus] id_link_address_o;
wire[`RegBus] id_current_inst_address_o;
wire[31:0] id_excepttype_o;


wire next_inst_in_delayslot_o;
wire[`RegBus] id_inst_o;
wire            id_reg1_is_imm;
wire            id_reg2_is_imm;

//id --> pc
wire id_branch_flag_o;
wire[`RegBus] branch_target_address;

//id/ex --> id
wire id_is_in_delayslot_o;
 
// id --> ctrl
wire id_stallreq_o;

// id/ex --> ex
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegBus] ex_reg1_i;
wire[`RegBus] ex_reg2_i;
wire ex_wreg_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_is_in_delayslot_i;
wire[`RegBus] ex_link_address_i;
wire[`RegBus] ex_inst;
wire[`RegAddrBus]   ex_reg1_addr;
wire[`RegAddrBus]   ex_reg2_addr;
wire                ex_reg1_is_imm;
wire                ex_reg2_is_imm;

// id/ex --> id (forward)
wire is_in_delayslot_i;
wire ex_cp0_reg_we_o;
wire[4:0] ex_cp0_reg_write_addr_o;
wire[`RegBus] ex_cp0_reg_data_o; 
wire[31:0] ex_excepttype_i;	
wire[`RegBus] ex_current_inst_address_i;	

// ex --> ex/mem
wire[`AluOpBus] ex_aluop_o;
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;
wire        ex_is_load_o;
wire[31:0] ex_excepttype_o;
wire ex_is_in_delayslot_o;
wire[`RegBus] ex_current_inst_address_o;
wire[`RegBus] ex_reg2_o;
wire[`RegBus] ex_mem_addr_o;

// ex --> ctrl
wire ex_stallreq_o;

// ex/mem --> mem
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;
wire[`AluOpBus] mem_aluop;
wire[`RegBus] mem_mem_addr;
wire[`RegBus] mem_reg2;
wire mem_cp0_reg_we_i;
wire[4:0] mem_cp0_reg_write_addr_i;
wire[`RegBus] mem_cp0_reg_data_i;

wire[31:0] mem_excepttype_i;
wire mem_is_in_delayslot_i;
wire[`RegBus] mem_current_inst_address_i;	


// mem -> mem/wb
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;
wire mem_wstate_o;
wire mem_wstate_i;

assign wstate_o = mem_wstate_i; // to mmu

// mem -> id
wire mem_is_load_o;
// mem -> ex
wire mem_cp0_reg_we_o;
wire[4:0] mem_cp0_reg_write_addr_o;
wire[`RegBus] mem_cp0_reg_data_o;	

// mem --> ctrl
wire mem_stallreq_o;
wire[31:0] mem_excepttype_o;
wire[`RegBus] latest_epc;


// mem/wb --> wb(regfile)
wire wb_wreg_i;
wire[`RegAddrBus] wb_wd_i;
wire[`RegBus] wb_wdata_i;

// id --> regfile
wire reg1_read;
wire reg2_read;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

// regfile --> id
wire[`RegBus] reg1_data;
wire[`RegBus] reg2_data;

//mem/wb --> cp0 & ex
wire wb_cp0_reg_we_i;
wire[4:0] wb_cp0_reg_write_addr_i;
wire[`RegBus] wb_cp0_reg_data_i;	

//mem --> cp0
wire[`RegBus] mem_current_inst_address_o;	
wire mem_is_in_delayslot_o;


//ex --> cp0
wire[4:0] cp0_raddr_i;

//cp0 --> ex
wire[`RegBus] cp0_data_o;

//cp0 --> mem
wire[`RegBus]	cp0_status;
wire[`RegBus]	cp0_cause;
wire[`RegBus]	cp0_epc;

// ctrl --> *
wire[0:5] ctrl_stall;
wire flush;

//ctrl --> pc
wire[`RegBus] new_pc;


// PC instance
pc_reg pc_reg0(
    .clk(clk),
    .rst(rst),

    //from id
    .branch_flag_i(id_branch_flag_o),
    .branch_target_address_i(branch_target_address),

    // from ctrl
    .stall(ctrl_stall),
	.new_pc(new_pc),
    .flush(flush),

    // to inst_ram
    .pc(pc),
    .ce(ram_ce_o)
);

assign debug2_o = pc;

assign ram_addr_o = pc; // output to inst_ram

// IF/ID instance
if_id if_id0(
    .clk(clk),
    .rst(rst),

    // from inst_ram
    .if_pc(pc),
    .if_inst(ram_inst_i),

    // from ctrl
    .stall(ctrl_stall),
    .flush(flush),


    // to id
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

// ID instance
id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

    // from regfile
    .reg1_data_i(reg1_data),
    .reg2_data_i(reg2_data),

    // forward from mem
    .mem_wreg_i(mem_wreg_i),
    .mem_wd_i(mem_wd_i),
    .mem_wdata_i(mem_wdata_i),
    .mem_is_load_i(mem_is_load_o),  // special conflict 2, wait 1 clk

    // forward from ex
    .ex_wreg_i(ex_wreg_o),
    .ex_wd_i(ex_wd_o),
    .ex_wdata_i(ex_wdata_o),
    .ex_is_load_i(ex_is_load_o), // special conflict 1, wait 2 clks

    // signals to regfile
    .reg1_read_o(reg1_read),
    .reg2_read_o(reg2_read),
    .reg1_addr_o(reg1_addr),
    .reg2_addr_o(reg2_addr), 
    
    // signals to id/ex
    .aluop_o(id_aluop_o),
    .alusel_o(id_alusel_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .wd_o(id_wd_o),
    .wreg_o(id_wreg_o),
    .inst_o(id_inst_o),
    .excepttype_o(id_excepttype_o),
    .current_inst_address_o(id_current_inst_address_o),

    .next_inst_in_delayslot_o(next_inst_in_delayslot_o),
    .branch_flag_o(id_branch_flag_o),
    .branch_target_address_o(branch_target_address),
    .link_addr_o(id_link_address_o),
    .is_in_delayslot_o(id_is_in_delayslot_o),

    .reg1_is_imm(id_reg1_is_imm),
    .reg2_is_imm(id_reg2_is_imm),

    //from id/ex
    .is_in_delayslot_i(is_in_delayslot_i),

    // to ctrl
    .stallreq_o(id_stallreq_o)
);

// regfile instance
regfile regfile0(
    .clk(clk),
    .rst(rst),
    .we(wb_wreg_i),
    .waddr(wb_wd_i),
    .wdata(wb_wdata_i),
    .re1(reg1_read),
    .raddr1(reg1_addr),
    .rdata1(reg1_data),
    .re2(reg2_read),
    .raddr2(reg2_addr),
    .rdata2(reg2_data),
    .debug1_o(debug1_o)  // ** debug signal
    // .debug2_o(debug2_o)  // ** debug signal
);

// ID/EX instance
id_ex id_ex0(
    .clk(clk),
    .rst(rst),
    
    // from id
    .id_aluop(id_aluop_o),
    .id_alusel(id_alusel_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_wd(id_wd_o),
    .id_wreg(id_wreg_o),
    .id_current_inst_address(id_current_inst_address_o),

    .id_link_address(id_link_address_o),
    .id_is_in_delayslot(id_is_in_delayslot_o),
    .next_inst_in_delayslot_i(next_inst_in_delayslot_o),
    .id_inst(id_inst_o),
    .id_reg1_addr(reg1_addr),
    .id_reg2_addr(reg2_addr),
    .id_reg1_is_imm(id_reg1_is_imm),
    .id_reg2_is_imm(id_reg2_is_imm),
    .id_excepttype(id_excepttype_o),

    // from ctrl
    .stall(ctrl_stall),
    .flush(flush),

    // to ex
    .ex_aluop(ex_aluop_i),
    .ex_alusel(ex_alusel_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_wd(ex_wd_i),
    .ex_wreg(ex_wreg_i),
    .ex_link_address(ex_link_address_i),
    .ex_is_in_delayslot(ex_is_in_delayslot_i),
    .is_in_delayslot_o(is_in_delayslot_i),
    .ex_inst(ex_inst),
    .ex_reg1_addr(ex_reg1_addr),
    .ex_reg2_addr(ex_reg2_addr),
    .ex_reg1_is_imm(ex_reg1_is_imm),
    .ex_reg2_is_imm(ex_reg2_is_imm),
    .ex_excepttype(ex_excepttype_i),
	.ex_current_inst_address(ex_current_inst_address_i)	

    // to id
);		

// EX instance
ex ex0(
    .rst(rst),

    // from id/ex
    .aluop_i(ex_aluop_i),
    .alusel_i(ex_alusel_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .wd_i(ex_wd_i),
    .wreg_i(ex_wreg_i),

    // to ex/mem and forward to id
    .wd_o(ex_wd_o),
    .wreg_o(ex_wreg_o),
    .wdata_o(ex_wdata_o),
    .aluop_o(ex_aluop_o),
    .mem_addr_o(ex_mem_addr_o),
    .reg2_o(ex_reg2_o),
    .is_load_o(ex_is_load_o), // special conflict 1

    //from id/ex
    .link_address_i(ex_link_address_i),
    .is_in_delayslot_i(ex_is_in_delayslot_i),
    .inst_i(ex_inst),
    .reg1_addr_i(ex_reg1_addr),
    .reg2_addr_i(ex_reg2_addr),
    .reg1_is_imm(ex_reg1_is_imm),
    .reg2_is_imm(ex_reg2_is_imm),
    .current_inst_address_i(ex_current_inst_address_i),
    .excepttype_i(ex_excepttype_i),

    //from mem/wb
    .wb_cp0_reg_we(wb_cp0_reg_we_i),
	.wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
	.wb_cp0_reg_data(wb_cp0_reg_data_i),

    //to cp0
    .cp0_reg_read_addr_o(cp0_raddr_i),

    //from cp0
    .cp0_reg_data_i(cp0_data_o),

    //to ex/mem
    .cp0_reg_we_o(ex_cp0_reg_we_o),
	.cp0_reg_write_addr_o(ex_cp0_reg_write_addr_o),
	.cp0_reg_data_o(ex_cp0_reg_data_o),

    .excepttype_o(ex_excepttype_o),
    .is_in_delayslot_o(ex_is_in_delayslot_o),
    .current_inst_address_o(ex_current_inst_address_o),

    //from mem
    .mem_cp0_reg_we(mem_cp0_reg_we_o),
	.mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
    .mem_cp0_reg_data(mem_cp0_reg_data_o),


    // to ctrl
    .stallreq_o(ex_stallreq_o)
);

// ex/mem instance
ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
    
    // from ex
    .ex_wd(ex_wd_o),
    .ex_wreg(ex_wreg_o),
    .ex_wdata(ex_wdata_o),
    .ex_aluop(ex_aluop_o),
    .ex_mem_addr(ex_mem_addr_o),
    .ex_reg2(ex_reg2_o),

    .ex_cp0_reg_we(ex_cp0_reg_we_o),
    .ex_cp0_reg_write_addr(ex_cp0_reg_write_addr_o),
    .ex_cp0_reg_data(ex_cp0_reg_data_o),

    .ex_excepttype(ex_excepttype_o),
    .ex_is_in_delayslot(ex_is_in_delayslot_o),
    .ex_current_inst_address(ex_current_inst_address_o),	

    // from ctrl
    .stall(ctrl_stall),
    .flush(flush),

    //to mem
    .mem_cp0_reg_we(mem_cp0_reg_we_i),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_i),
    .mem_cp0_reg_data(mem_cp0_reg_data_i),

    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_aluop(mem_aluop),
    .mem_mem_addr(mem_mem_addr),
    .mem_reg2(mem_reg2),                   

    .mem_excepttype(mem_excepttype_i),
  	.mem_is_in_delayslot(mem_is_in_delayslot_i),
	.mem_current_inst_address(mem_current_inst_address_i)    

);

// data memory instance
mem mem0(
    .rst(rst),

    // from ex/mem
    .wd_i(mem_wd_i),
    .wreg_i(mem_wreg_i),
    .wdata_i(mem_wdata_i),
    .aluop_i(mem_aluop),
    .mem_addr_i(mem_mem_addr),
    .reg2_i(mem_reg2),
    
    .cp0_reg_we_i(mem_cp0_reg_we_i),
    .cp0_reg_write_addr_i(mem_cp0_reg_write_addr_i),
    .cp0_reg_data_i(mem_cp0_reg_data_i),
    .excepttype_i(mem_excepttype_i),
    .is_in_delayslot_i(mem_is_in_delayslot_i),
    .current_inst_address_i(mem_current_inst_address_i),

    .wb_cp0_reg_we(wb_cp0_reg_we_i),
    .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
    .wb_cp0_reg_data(wb_cp0_reg_data_i),	 	

    //from cp0
    .cp0_status_i(cp0_status),
	.cp0_cause_i(cp0_cause),
	.cp0_epc_i(cp0_epc),

    // to mem/wb and forward to id
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),
    .wstate_o(mem_wstate_o), // to mem/wb and then to mem itself
    .wstate_i(mem_wstate_i), // from mem/wb

    //to mmu
    .mem_addr_o(mem_addr_o),
    .mem_we_o(mem_we_o),
    .mem_data_o(mem_data_o),
    .mem_ce_o(mem_ce_o),
    .mem_sel_o(mem_sel_o),

    // to ex
    .is_load_o(mem_is_load_o),

    //from mmu
    .mem_data_i(mmu_mem_data_i),

    // to mem/wb
    .cp0_reg_we_o(mem_cp0_reg_we_o),
    .cp0_reg_write_addr_o(mem_cp0_reg_write_addr_o),
    .cp0_reg_data_o(mem_cp0_reg_data_o),

    // to ctrl
    .excepttype_o(mem_excepttype_o),
    .cp0_epc_o(latest_epc),

    //to cp0
    .is_in_delayslot_o(mem_is_in_delayslot_o),
	.current_inst_address_o(mem_current_inst_address_o),

    // to ctrl
    .stallreq_o(mem_stallreq_o)
);

// MEM/WB instance
mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),

    // from mem
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),
    .mem_wstate_i(mem_wstate_o),
    .wstate_o(mem_wstate_i),

    .mem_cp0_reg_we(mem_cp0_reg_we_o),
    .mem_cp0_reg_write_addr(mem_cp0_reg_write_addr_o),
    .mem_cp0_reg_data(mem_cp0_reg_data_o),	

    // from ctrl
    .stall(ctrl_stall),
    .flush(flush),


    // to wb(regfile)
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i),  

    //to cp0 & ex
    .wb_cp0_reg_we(wb_cp0_reg_we_i),   
    .wb_cp0_reg_write_addr(wb_cp0_reg_write_addr_i),
    .wb_cp0_reg_data(wb_cp0_reg_data_i)						
          
);

coprocessor0 cp_0(
    
    .clk(clk),
    .rst(rst),
    
    .we_i(wb_cp0_reg_we_i),
    .waddr_i(wb_cp0_reg_write_addr_i),
    .raddr_i(cp0_raddr_i),
    .data_i(wb_cp0_reg_data_i),
    

    //from mem            
    .excepttype_i(mem_excepttype_o),
    .current_inst_addr_i(mem_current_inst_address_o),
    .is_in_delayslot_i(mem_is_in_delayslot_o),

    // from top level
    .uart_int_i(uart_int_i),

    // to ex
    .data_o(cp0_data_o),

    //to mem
    .status_o(cp0_status),
    .cause_o(cp0_cause),
    .epc_o(cp0_epc)

);

// CTRL instance
ctrl ctrl0(
    .rst(rst),

    .id_stallreq_i(id_stallreq_o),
    .ex_stallreq_i(ex_stallreq_o),
    .mem_stallreq_i(mem_stallreq_o),
    .mmu_stallreq_i(mmu_stallreq_i),

    .excepttype_i(mem_excepttype_o),
	.cp0_epc_i(latest_epc),
    .new_pc(new_pc),
	.flush(flush),


    .stall_o(ctrl_stall)
);

endmodule // mips
