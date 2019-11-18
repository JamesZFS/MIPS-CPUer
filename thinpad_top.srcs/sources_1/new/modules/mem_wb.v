module mem_wb(
    input wire      clk,
    input wire      rst,

    // singals from mem
    input wire                    mem_wreg,
    input wire[`RegAddrBus]       mem_wd,
    input wire[`RegBus]           mem_wdata,

    input wire[0:5]               stall, // from ctrl

    // signals to wb
    output reg                    wb_wreg,
    output reg[`RegAddrBus]       wb_wd,
    output reg[`RegBus]           wb_wdata
);

always @(posedge clk) begin  // ** needs extending **
    if (rst == `RstEnable || (stall[4] == `StallEnable && stall[5] == `StallDisable)) begin
        // reset or ** at the tail of a stall sequence
        wb_wreg  <= `WriteDisable;
        wb_wd    <= `NOPRegAddr;
        wb_wdata <= `ZeroWord;
    end else if (stall[4] == `StallDisable) begin
        wb_wreg  <= mem_wreg;
        wb_wd    <= mem_wd;
        wb_wdata <= mem_wdata;
    end // else: hold on
end

endmodule // mem_wb