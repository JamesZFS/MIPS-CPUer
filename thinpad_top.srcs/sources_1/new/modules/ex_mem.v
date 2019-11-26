module ex_mem(
    input wire      clk,
    input wire      rst,

    // singals from ex
    input wire                    ex_wreg,
    input wire[`RegAddrBus]       ex_wd,
    input wire[`RegBus]           ex_wdata,

    input wire[`AluOpBus]         ex_aluop,
    input wire[`RegBus]           ex_mem_addr,
    input wire[`RegBus]           ex_reg2,


    input wire[0:5]               stall, // from ctrl

    // signals to mem
    output reg                    mem_wreg,
    output reg[`RegAddrBus]       mem_wd,
    output reg[`RegBus]           mem_wdata,

    output reg[`AluOpBus]         mem_aluop,
    output reg[`RegBus]           mem_mem_addr,
    output reg[`RegBus]           mem_reg2

);

always @(posedge clk) begin
    if (rst == `RstEnable || (stall[3] == `StallEnable && stall[4] == `StallDisable)) begin
        // reset or ** at the tail of a stall sequence
        mem_wreg  <= `WriteDisable;
        mem_wd    <= `NOPRegAddr;
        mem_wdata <= `ZeroWord;
        mem_aluop <= `EXE_NOP_OP;
        mem_mem_addr <= `ZeroWord;
        mem_reg2 <= `ZeroWord;
    end else if (stall[3] == `StallDisable) begin
        mem_wreg  <= ex_wreg;
        mem_wd    <= ex_wd;
        mem_wdata <= ex_wdata;
        mem_aluop <= ex_aluop;
        mem_mem_addr <=ex_mem_addr;
        mem_reg2 <= ex_reg2;
    end // else: hold on

end

endmodule // ex_mem
