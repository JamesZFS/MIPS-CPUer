module mem(
    input wire      rst,

    // singals from ex
    input wire                    wreg_i,
    input wire[`RegAddrBus]       wd_i,
    input wire[`RegBus]           wdata_i,

    // signals to wb (and forward to id)
    output reg                    wreg_o,
    output reg[`RegAddrBus]       wd_o,
    output reg[`RegBus]           wdata_o,
    
    // to ctrl
    output reg                    stallreq_o
);

always @* begin // ** needs extending **
    if (rst == `RstEnable) begin
        wreg_o  <= `WriteDisable;
        wd_o    <= `NOPRegAddr;
        wdata_o <= `ZeroWord;
    end else begin
        wreg_o  <= wreg_i;
        wd_o    <= wd_i;
        wdata_o <= wdata_i;
    end
end

// assign stallreq_o = `StallDisable;
always @* begin
    if (rst == `RstEnable)
        stallreq_o <= `StallDisable;
    else
        stallreq_o <= `StallDisable;
end

endmodule // mem
