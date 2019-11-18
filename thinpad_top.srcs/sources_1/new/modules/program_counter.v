
module pc_reg(
    input   wire    clk,
    input   wire    rst,

    // from ctrl
    input wire[0:5]             stall,

    // to rom
    output  reg[`InstAddrBus]   pc,
    output  reg                 ce
);

always @ (posedge clk) begin
    if (rst == `RstEnable)
        ce <= `ChipDisable;
    else
        ce <= `ChipEnable;
end

always @ (posedge clk) begin
    if (ce == `ChipEnable)
        pc <= pc + 4;
    else if (stall[0] == `StallDisable)
        pc <= `ZeroWord;
    // else: when stalling, hold pc
end

endmodule   // pc_reg
