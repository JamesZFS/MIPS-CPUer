module mem_wb(
    input wire      clk,
    input wire      rst,

    // singals from mem
    input wire                    mem_wreg,
    input wire[`RegAddrBus]       mem_wd,
    input wire[`RegBus]           mem_wdata,
    input wire                    mem_wstate_i,
    output reg                    wstate_o, // to mem & mmu

    input wire                    mem_cp0_reg_we,
	input wire[4:0]               mem_cp0_reg_write_addr,
	input wire[`RegBus]           mem_cp0_reg_data,	

    // from ctrl
    input wire[0:5]               stall,
    input wire                    flush,

    output reg                    wb_cp0_reg_we,
	output reg[4:0]               wb_cp0_reg_write_addr,
	output reg[`RegBus]           wb_cp0_reg_data,

    // signals to wb
    output reg                    wb_wreg,
    output reg[`RegAddrBus]       wb_wd,
    output reg[`RegBus]           wb_wdata
);

always @(posedge clk) begin  // ** needs extending **
    if (rst == `RstEnable || flush == 1'b1) begin
        // reset or ** at the tail of a stall sequence
        wb_wreg  <= `WriteDisable;
        wb_wd    <= `NOPRegAddr;
        wb_wdata <= `ZeroWord;
        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZeroWord;
        wstate_o <= 0;

    end else if (stall[4] == `StallEnable && stall[5] == `StallDisable) begin
        wb_wreg  <= `WriteDisable;
        wb_wd    <= `NOPRegAddr;
        wb_wdata <= `ZeroWord;
        wb_cp0_reg_we <= `WriteDisable;
        wb_cp0_reg_write_addr <= 5'b00000;
        wb_cp0_reg_data <= `ZeroWord;
        wstate_o <= mem_wstate_i;

    end else if (stall[4] == `StallDisable) begin
        wb_wreg  <= mem_wreg;
        wb_wd    <= mem_wd;
        wb_wdata <= mem_wdata;
        wb_cp0_reg_we <= mem_cp0_reg_we;
		wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
		wb_cp0_reg_data <= mem_cp0_reg_data;
        wstate_o <= 0;

    end // else: hold on
end

endmodule // mem_wb