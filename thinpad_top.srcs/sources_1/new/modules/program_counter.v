
module pc_reg(
    input   wire    clk,
    input   wire    rst,

    output  reg[`InstAddrBus]   pc,     // inout or output?
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
    else
        pc <= `ZeroWord;
end

endmodule   // pc_reg
