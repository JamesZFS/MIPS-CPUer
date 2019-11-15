module ex_mem(
    input wire      clk,
    input wire      rst,

    // singals from ex
    input wire                    ex_wreg,
    input wire[`RegAddrBus]       ex_wd,
    input wire[`RegBus]           ex_wdata,

    // signals to mem
    output reg                    mem_wreg,
    output reg[`RegAddrBus]       mem_wd,
    output reg[`RegBus]           mem_wdata
);

always @(clk) begin
    if (rst == `RstEnable) begin
        mem_wreg  <= `WriteDisable;
        mem_wd    <= `NOPRegAddr;
        mem_wdata <= `ZeroWord;
    end else begin
        mem_wreg  <= ex_wreg;
        mem_wd    <= ex_wd;
        mem_wdata <= ex_wdata;
    end
end

endmodule // ex_mem
