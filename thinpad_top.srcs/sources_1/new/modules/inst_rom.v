
module inst_rom(
	input wire                  ce,
	input wire[`InstAddrBus]	addr,
	output reg[`InstBus]		inst
);

reg[`InstBus]  inst_mem[0: `InstMemNum - 1];

// initial $readmemh ( "inst_rom.data", inst_mem );
// TODO: you must use the ABSOLUTE path of the rom data file!
initial $readmemh ( "C:/Users/admin/CPUer/cod19grp16/testcases/inst_rom.data", inst_mem );

always @ (*) begin
    if (ce == `ChipDisable) begin
        inst <= `ZeroWord;  
    end else begin
        inst <= inst_mem[addr[`InstMemNumLog2 + 1: 2]];    // inst_mem[addr / 4]
    end
end

endmodule