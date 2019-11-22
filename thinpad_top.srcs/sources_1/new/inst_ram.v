module inst_ram(
    // input wire                  clk,
    // from mips
    input wire                  ce,
    input wire[`InstAddrBus]	addr,  // pc

    // to mips
	output reg[`InstBus]		inst,

    // ** inout with BaseRam
    inout wire[31:0]            base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享

    // output to BaseRam
    output wire[19:0]           base_ram_addr,  //BaseRAM地址
    output reg                  base_ram_ce_n,  //BaseRAM片选，低有效
    output reg                  base_ram_oe_n,  //BaseRAM读使能，低有效
    output reg                  base_ram_we_n  //BaseRAM写使能，低有效
);


reg[31:0] inner_ram_data;
// reg       ce_n;
// reg       oe_n;
// reg       we_n;

assign base_ram_data = inner_ram_data;
assign base_ram_addr = addr[19: 2];  // div 4
// assign base_ram_ce_n = ce_n
// assign base_ram_oe_n = oe_n;
// assign base_ram_we_n = we_n;

always @(*) begin
    if (ce == `ChipDisable) begin
        inner_ram_data <= 32'b0;
        base_ram_ce_n <= `RAMDisable;
        base_ram_oe_n <= `RAMDisable;
        base_ram_we_n <= `RAMDisable;
    end else begin
        inner_ram_data <= 32'bz;  // ** high resistance state
        base_ram_ce_n <= `RAMEnable;
        base_ram_oe_n <= `RAMEnable;
        base_ram_we_n <= `RAMDisable;
    end
end

always @* begin
    if (ce == `ChipDisable) begin
        inst = `ZeroWord;
    end else begin // endian conversion
        inst[7:0]   = base_ram_data[31:24];
        inst[15:8]  = base_ram_data[23:16];
        inst[23:16] = base_ram_data[15:8];
        inst[31:24] = base_ram_data[7:0];    
    end
end


endmodule // inst_ram