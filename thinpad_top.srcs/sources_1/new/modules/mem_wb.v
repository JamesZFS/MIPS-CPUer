module mem_wb(
    input wire      clk,
    input wire      rst,

    // singals from mem
    input wire                    mem_wreg,
    input wire[`RegAddrBus]       mem_wd,
    input wire[`RegBus]           mem_wdata,

    // signals to wb
    output reg                    wb_wreg,
    output reg[`RegAddrBus]       wb_wd,
    output reg[`RegBus]           wb_wdata
);

always @(clk) begin  // ** needs extending **
    if (rst == `RstEnable) begin
        wb_wreg  <= `WriteDisable;
        wb_wd    <= `NOPRegAddr;
        wb_wdata <= `ZeroWord;
    end else begin
        wb_wreg  <= mem_wreg;
        wb_wd    <= mem_wd;
        wb_wdata <= mem_wdata;
    end
end

endmodule // mem_wb