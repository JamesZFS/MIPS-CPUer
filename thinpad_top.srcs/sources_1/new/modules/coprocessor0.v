
module coprocessor0(

	input wire   				  clk,
	input wire					  rst,
	
	input wire                    we_i,
	input wire[4:0]               waddr_i,
	input wire[4:0]               raddr_i,
	input wire[`RegBus]           data_i,
	
	input wire[31:0]              excepttype_i,
	input wire[`RegBus]           current_inst_addr_i,
	input wire                    is_in_delayslot_i,

	// from top, hardware interruptions:
	input wire 					  uart_int_i, // uart interruption
	
	output reg[`RegBus]           data_o,
	output reg[`RegBus]           status_o,
	output reg[`RegBus]           cause_o,
	output reg[`RegBus]           epc_o,
	output reg[`RegBus]           ebase_o
);

reg uart_int_prev;

always @(posedge clk) begin
	if (rst == `RstEnable)
		uart_int_prev <= 0;
	else
		uart_int_prev <= uart_int_i;
end

always @ (posedge clk) begin
	
	if(rst == `RstEnable) begin
		status_o <= 32'b00010000000000000000000000000000;
		cause_o <= `ZeroWord;
		epc_o <= `ZeroWord;
		ebase_o <= 32'h80001000; // defined by the supervisor
	end else begin
		if (uart_int_prev == 0 && uart_int_i == 1)	
			cause_o[10] <= 1'b1; // cause[10], i.e. IP[2] means uart interrupt, see P291
	
		if (we_i == `WriteEnable) begin
			case (waddr_i) 
				`CP0_REG_STATUS:	begin
					status_o <= data_i;
				end
				`CP0_REG_EPC:	begin
					epc_o <= data_i;
				end
				`CP0_REG_CAUSE:	begin
					cause_o[9:8] <= data_i[9:8];
					cause_o[23] <= data_i[23];
					cause_o[22] <= data_i[22];
				end
				`CP0_REG_EBASE: begin
					ebase_o <= data_i;
				end
				default: $display("invalid cp0 reg %d for write!", raddr_i);
			endcase  //case addr_i
		end
		case (excepttype_i)
			32'h00000001:		begin // uart IRQ
				if(is_in_delayslot_i == `InDelaySlot ) begin
					epc_o <= current_inst_addr_i - 4 ;
					cause_o[31] <= 1'b1;
				end else begin
					epc_o <= current_inst_addr_i;
					cause_o[31] <= 1'b0;
				end
				status_o[1] <= 1'b1;
				cause_o[10] <= 1'b0;  // clear exception signal
				cause_o[6:2] <= 5'b00000;
			end
			32'h00000008:		begin // syscall
				if(status_o[1] == 1'b0) begin
					if(is_in_delayslot_i == `InDelaySlot ) begin
						epc_o <= current_inst_addr_i - 4 ;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
				end
				status_o[1] <= 1'b1;
				cause_o[6:2] <= 5'b01000;			
			end
			32'h0000000a:		begin // invalid inst
				if(status_o[1] == 1'b0) begin
					if(is_in_delayslot_i == `InDelaySlot ) begin
						epc_o <= current_inst_addr_i - 4 ;
						cause_o[31] <= 1'b1;
					end else begin
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
				end
				status_o[1] <= 1'b1;
				cause_o[6:2] <= 5'b01010;					
			end
			// 32'h0000000d:		begin	// 
			// 	if(status_o[1] == 1'b0) begin
			// 		if(is_in_delayslot_i == `InDelaySlot ) begin
			// 			epc_o <= current_inst_addr_i - 4 ;
			// 			cause_o[31] <= 1'b1;
			// 		end else begin
			// 			epc_o <= current_inst_addr_i;
			// 			cause_o[31] <= 1'b0;
			// 		end
			// 	end
			// 	status_o[1] <= 1'b1;
			// 	cause_o[6:2] <= 5'b01101;					
			// end
			32'h0000000c:		begin
				if(status_o[1] == 1'b0) begin
					if(is_in_delayslot_i == `InDelaySlot ) begin
						epc_o <= current_inst_addr_i - 4 ;
						cause_o[31] <= 1'b1;
					end else begin
					epc_o <= current_inst_addr_i;
					cause_o[31] <= 1'b0;
					end
				end
				status_o[1] <= 1'b1;
				cause_o[6:2] <= 5'b01100;					
			end
			32'h0000000e:   begin
				status_o[1] <= 1'b0;
			end
			default:;
		endcase	
	end    //if
end      //always
		
always @ (*) begin
	data_o <= `ZeroWord;
	if(rst == `RstEnable) begin
		data_o <= `ZeroWord;
	end else begin
		case (raddr_i) 
			`CP0_REG_STATUS:	begin
				data_o <= status_o ;
			end
			`CP0_REG_CAUSE:	begin
				data_o <= cause_o ;
			end
			`CP0_REG_EPC:	begin
				data_o <= epc_o ;
			end
			`CP0_REG_EBASE:	begin
				data_o <= ebase_o ;
			end
			default:; // $display("invalid cp0 reg %d for read!", raddr_i);
		endcase  //case addr_i			
	end    //if
end      //always

endmodule