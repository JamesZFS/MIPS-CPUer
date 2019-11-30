
module pc_reg(
    input   wire    clk,
    input   wire    rst,

    // from ctrl
    input wire[0:5]             stall,
    input wire[`InstAddrBus]    new_pc,
    input wire                  flush,

    //for jmp
    input wire                  branch_flag_i,
    input wire[`RegBus]         branch_target_address_i,
    
    // to rom
    output  reg[`InstAddrBus]   pc,
    output  reg                 ce
);

always @ (posedge clk) begin
    if (rst == `RstEnable) begin
        ce <= `ChipDisable;
        pc <= 32'b0;
        
    end else begin
        ce <= `ChipEnable;

        if (flush == 1'b1) begin
            $display("clk!  pc new = 0x%8x", pc);
            pc <= new_pc;
        end else if (branch_flag_i == `Branch && stall[2] == `StallDisable) begin 
            $display("branching");
            pc <= branch_target_address_i;
        end else if (stall[0] == `StallDisable) begin
            $display("clk!  pc = 0x%8x", pc);
            pc <= pc + 4;
        end else if (stall[0]==`StallEnable) begin // else: when stalling, hold pc
            $display("hold pc");
            pc <= pc;
        end

    end
end

endmodule   // pc_reg
