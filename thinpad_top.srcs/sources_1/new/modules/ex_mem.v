module ex_mem(
    input wire      clk,
    input wire      rst,

    // singals from ex
    input wire                    ex_wreg,
    input wire[`RegAddrBus]       ex_wd,
    input wire[`RegBus]           ex_wdata,

    input wire[0:5]               stall, // from ctrl

    // signals to mem
    output reg                    mem_wreg,
    output reg[`RegAddrBus]       mem_wd,
    output reg[`RegBus]           mem_wdata
);

always @(posedge clk) begin
    if (rst == `RstEnable || (stall[3] == `StallEnable && stall[4] == `StallDisable)) begin
        // reset or ** at the tail of a stall sequence
        mem_wreg  <= `WriteDisable;
        mem_wd    <= `NOPRegAddr;
        mem_wdata <= `ZeroWord;
    end else if (stall[3] == `StallDisable) begin
        mem_wreg  <= ex_wreg;
        mem_wd    <= ex_wd;
        mem_wdata <= ex_wdata;
    end // else: hold on
end

endmodule // ex_mem
