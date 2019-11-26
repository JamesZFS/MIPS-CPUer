
module pc_reg(
    input   wire    clk,
    input   wire    rst,

    // from ctrl
    input wire[0:5]             stall,

    //for jmp
    input wire                  branch_flag_i,
    input wire[`RegBus]         branch_target_address_i,
    // to rom
    output  reg[`InstAddrBus]   pc,
    output  reg                 ce
);

always @ (posedge clk) begin
    if (rst == `RstEnable)
        ce <= `ChipDisable;
    else
        ce <= `ChipEnable;
end

always @ (posedge clk) begin
    if (ce == `ChipDisable)
        pc <= `InstAddrLog2'b0;
    else if (branch_flag_i == `Branch && stall[2] == `StallDisable) begin 
        pc <= branch_target_address_i;
    end else if (stall[0] == `StallDisable) begin
        pc <= pc + 4;
    end else if (stall[0]==`StallEnable) begin
        pc <= pc;
    end
    // else: when stalling, hold pc
end

endmodule   // pc_reg
