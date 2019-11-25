module mips(
    input wire      clk,
    input wire      rst,

    // from mmu
    input wire[31:0]         mmu_mem_data_i,
    input wire[31:0]         ram_inst_i,    // instruction input
    input wire               mmu_stallreq_i, // to ctrl
    
    // if-id to mmu
    output wire[`InstAddrBus]    ram_addr_o,
    output wire                  ram_ce_o,

    // mem to mmu
    output wire[`RegBus]         mem_addr_o,
    output wire                  mem_we_o,
    output wire[`RegBus]         mem_data_o,
    output wire                  mem_ce_o,
    output wire[3:0]             mem_sel_o,

    output wire[`RegBus]         debug_o        // signal for debug display
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
wire next_inst_in_delayslot_o;
wire[`RegBus] id_inst_o;

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

// id/ex --> id (forward)
wire is_in_delayslot_i;

// ex --> ex/mem
wire ex_wreg_o;
wire[`RegAddrBus] ex_wd_o;
wire[`RegBus] ex_wdata_o;
wire[`AluOpBus] aluop_o;
wire[`RegBus] ex_mem_addr_o;
wire[`RegBus] reg2_o;

// ex --> ctrl
wire ex_stallreq_o;

// ex/mem --> mem
wire mem_wreg_i;
wire[`RegAddrBus] mem_wd_i;
wire[`RegBus] mem_wdata_i;
wire[`AluOpBus] mem_aluop;
wire[`RegBus] mem_mem_addr;
wire[`RegBus] mem_reg2;

// mem -> mem/wb
wire mem_wreg_o;
wire[`RegAddrBus] mem_wd_o;
wire[`RegBus] mem_wdata_o;

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


// ctrl --> *
wire[0:5] ctrl_stall;

// PC instance
pc_reg pc_reg0(
    .clk(clk),
    .rst(rst),

    //from id
    .branch_flag_i(id_branch_flag_o),
    .branch_target_address_i(branch_target_address),

    // from ctrl
    .stall(ctrl_stall),

    // to inst_ram
    .pc(pc),
    .ce(ram_ce_o)
);

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
    .mem_wreg_i(mem_wreg_o),
    .mem_wd_i(mem_wd_o),
    .mem_wdata_i(mem_wdata_o),

    // forward from ex
    .ex_wreg_i(ex_wreg_o),
    .ex_wd_i(ex_wd_o),
    .ex_wdata_i(ex_wdata_o),

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

    .next_inst_in_delayslot_o(next_inst_in_delayslot_o),
    .branch_flag_o(id_branch_flag_o),
    .branch_target_address_o(branch_target_address),
    .link_addr_o(id_link_address_o),
    .is_in_delayslot_o(id_is_in_delayslot_o),

    .inst_o(id_inst_o),

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
    .debug_o(debug_o)  // ** debug signal
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

    .id_link_address(id_link_address_o),
    .id_is_in_delayslot(id_is_in_delayslot_o),
    .next_inst_in_delayslot_i(next_inst_in_delayslot_o),
    .id_inst(id_inst_o),

    // from ctrl
    .stall(ctrl_stall),

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
    .ex_inst(ex_inst)

    // to id
);		

// EX instance
ex ex0(
    .rst(rst),

    // to ex
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
    .aluop_o(aluop_o),
    .mem_addr_o(ex_mem_addr_o),
    .reg2_o(reg2_o),

    //from id/ex
    .link_address_i(ex_link_address_i),
    .is_in_delayslot_i(ex_is_in_delayslot_i),
    .inst_i(ex_inst),

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
    .ex_aluop(aluop_o),
    .ex_mem_addr(ex_mem_addr_o),
    .ex_reg2(reg2_o),

    // from ctrl
    .stall(ctrl_stall),

    // to mem
    .mem_wd(mem_wd_i),
    .mem_wreg(mem_wreg_i),
    .mem_wdata(mem_wdata_i),
    .mem_aluop(mem_aluop),
    .mem_mem_addr(mem_mem_addr),
    .mem_reg2(mem_reg2)                    
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
    
    // to mem/wb and forward to id
    .wd_o(mem_wd_o),
    .wreg_o(mem_wreg_o),
    .wdata_o(mem_wdata_o),

    //to mmu
    .mem_addr_o(mem_addr_o),
    .mem_we_o(mem_we_o),
    .mem_data_o(mem_data_o),
    .mem_ce_o(mem_ce_o),
    .mem_sel_o(mem_sel_o),

    //from mmu
    .mem_data_i(mmu_mem_data_i)
);

// MEM/WB instance
mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),

    // from mem
    .mem_wd(mem_wd_o),
    .mem_wreg(mem_wreg_o),
    .mem_wdata(mem_wdata_o),

    // from ctrl
    .stall(ctrl_stall),

    // to wb(regfile)
    .wb_wd(wb_wd_i),
    .wb_wreg(wb_wreg_i),
    .wb_wdata(wb_wdata_i)                    
);

// CTRL instance
ctrl ctrl0(
    .rst(rst),

    .id_stallreq_i(id_stallreq_o),
    .ex_stallreq_i(ex_stallreq_o),
    .mmu_stallreq_i(mmu_stallreq_i),

    .stall_o(ctrl_stall)
);

endmodule // mips
