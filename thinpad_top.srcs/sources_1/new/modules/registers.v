module regfile(

    input   wire    clk,
    input   wire    rst,

    // write port
    input wire					we,
    input wire[`RegAddrBus]		waddr,
    input wire[`RegBus]			wdata,

    // read port1
    input wire					re1,
    input wire[`RegAddrBus]		raddr1,
    output reg[`RegBus]         rdata1,

    // read port2
    input wire					re2,
    input wire[`RegAddrBus]	    raddr2,
    output reg[`RegBus]         rdata2,

    // debug display
    output wire[`RegBus]        debug1_o,
    output wire[`RegBus]        debug2_o
);

// ** definition of 32 registers **
reg[`RegBus]  regs[0: `RegNum - 1];

initial begin
    for (integer i = 0; i < `RegNum; i = i + 1) begin
        regs[i] = `ZeroWord;
    end
end

always @ (posedge clk) begin    // ** write back here **
    if (rst == `RstEnable)
        for (integer i = 0; i < `RegNum; i = i + 1) begin // initialize when resetting
            regs[i] <= `ZeroWord;
        end
    else
        if((we == `WriteEnable) && (waddr != `RegNumLog2'h0))  // valid reg addr ($zero is protected)
            regs[waddr] <= wdata;   // regs are only updated synchronized with clk
end

always @ (*) begin      // read op, combination logic
    if (rst == `RstEnable) begin
        rdata1 <= `ZeroWord;
    end else if (raddr1 == `RegNumLog2'h0) begin
        rdata1 <= `ZeroWord;
    end else if ((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin   // ** conflict type 3
        rdata1 <= wdata;
    end else if (re1 == `ReadEnable) begin
        rdata1 <= regs[raddr1];
    end else begin  // read disable
        rdata1 <= `ZeroWord;
    end
end

always @ (*) begin
    if(rst == `RstEnable) begin
        rdata2 <= `ZeroWord;
    end else if (raddr2 == `RegNumLog2'h0) begin
        rdata2 <= `ZeroWord;
    end else if ((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin   // ** conflict type 3
        rdata2 <= wdata;
    end else if (re2 == `ReadEnable) begin
        rdata2 <= regs[raddr2];
    end else begin
        rdata2 <= `ZeroWord;
    end
end

assign debug1_o = regs[8];  // display the $t0 reg
assign debug2_o = regs[9];  // display the $t1 reg

endmodule  // regfile