module inst_ram(
    input wire                  clk,
    // from mips
    input wire                  ce,
    input wire[`InstAddrBus]	addr,

    // to mips
	output reg[`InstBus]		inst,

    // ** inout with BaseRam
    inout wire[31:0]            base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享

    // output to BaseRam
    output wire[19:0]           base_ram_addr,  //BaseRAM地址
    // output wire[3:0]            base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire                 base_ram_ce_n,  //BaseRAM片选，低有效
    output wire                 base_ram_oe_n,  //BaseRAM读使能，低有效
    output wire                 base_ram_we_n  //BaseRAM写使能，低有效
);

always @(*) begin
    
end


endmodule // inst_ram