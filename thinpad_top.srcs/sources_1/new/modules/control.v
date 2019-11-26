module ctrl(
    input wire      rst,
    
    input wire      id_stallreq_i,
    input wire      ex_stallreq_i,
    input wire      mmu_stallreq_i,

    // from 0 to 5: pc(0), if(1), id(2), ex(3), mem(4), wb(5)
    output reg[0:5] stall_o
);

always @* begin
    
    if (rst == `RstEnable) begin
        stall_o <= 6'b000000; // 0 means continue, 1 means stall enable
    end else begin
        if (ex_stallreq_i == `StallEnable)
            stall_o <= 6'b111100;
        else if (id_stallreq_i == `StallEnable)
            stall_o <= 6'b111000;
        else if (mmu_stallreq_i == `StallEnable)
            stall_o <= 6'b110000;
        else // no stalling request:
            stall_o <= 6'b000000;
    end

end

endmodule // ctrl