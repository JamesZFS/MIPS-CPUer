module ctrl(
    input wire      rst,
    
    input wire      id_stallreq_i,
    input wire      ex_stallreq_i,
    input wire      mem_stallreq_i,  // mem write stall
    input wire      mmu_stallreq_i,  // baseram bus conflict stall

    // from mem
    input wire[31:0]             excepttype_i,
	input wire[`RegBus]          cp0_epc_i,

    output reg[`RegBus]          new_pc,
	output reg                   flush,
    // from 0 to 5: pc(0), if(1), id(2), ex(3), mem(4), wb(5)
    output reg[0:5] stall_o
);

always @* begin
    new_pc <= `ZeroWord;
    flush <= 1'b0;
    
    if (rst == `RstEnable) begin
        stall_o <= 6'b000000; // 0 means continue, 1 means stall enable
        flush <= 1'b0;
		new_pc <= `ZeroWord;

    end else if(excepttype_i != `ZeroWord) begin

	    flush <= 1'b1;
	    stall_o <= 6'b000000;
        case (excepttype_i)           //new pc value for the exception handling
            32'h00000001:		begin   //interrupt
                new_pc <= `EHANDLERLOCATE;//`EHANDLERLOCATE;
            end
            32'h00000008:		begin   //syscall
                new_pc <= `EHANDLERLOCATE;
            end
            32'h0000000a:		begin   //inst_invalid
                new_pc <= `EHANDLERLOCATE;
            end
            32'h0000000e:		begin   //eret
                new_pc <= cp0_epc_i;
            end
            default: $display("unknown excepttype_i 0x%x in control.v", excepttype_i);
        endcase
    end else begin
        if (mem_stallreq_i == `StallEnable) begin
            stall_o <= 6'b111110;
        end else if (ex_stallreq_i == `StallEnable) begin
            stall_o <= 6'b111100;
        end else if (id_stallreq_i == `StallEnable) begin
            stall_o <= 6'b111000;
        end else if (mmu_stallreq_i == `StallEnable) begin
            stall_o <= 6'b110000;
        end else begin // cancel stalling request
            stall_o <= 6'b000000;
        end
    end

end

endmodule // ctrl