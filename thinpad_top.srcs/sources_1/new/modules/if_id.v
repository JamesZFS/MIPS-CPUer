module if_id(
    input   wire    clk,
    input   wire    rst,
	
    input wire[`InstAddrBus]	  if_pc,
    input wire[`InstBus]          if_inst,

    input wire[0:5]               stall, // from ctrl
    input wire                    flush,

    
    output reg[`InstAddrBus]      id_pc,
    output reg[`InstBus]          id_inst  
	
);

always @ (posedge clk) begin
    if (rst == `RstEnable || (stall[1] == `StallEnable && stall[2] == `StallDisable) || (flush == 1'b1)) begin
        // reset or ** at the tail of a stall sequence
        id_pc   <= `PC_INIT;
        id_inst <= `ZeroWord;	
    end else if (stall[1] == `StallDisable) begin // normal
        id_pc   <= if_pc;
        id_inst <= if_inst;
    end // else: inside a stall sequence, hold id_pc / id_inst
end

endmodule