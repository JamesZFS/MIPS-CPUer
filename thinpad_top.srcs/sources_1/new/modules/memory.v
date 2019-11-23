module mem(
    input wire      rst,

    // singals from ex
    input wire                    wreg_i,
    input wire[`RegAddrBus]       wd_i,
    input wire[`RegBus]           wdata_i,

    input wire[`AluOpBus]         aluop_i,
    input wire[`RegBus]           mem_addr_i,
    input wire[`RegBus]           reg2_i,

    //signal from RAM
    input wire[`RegBus]           mem_data_i,

    // signals to wb (and forward to id)
    output reg                    wreg_o,
    output reg[`RegAddrBus]       wd_o,
    output reg[`RegBus]           wdata_o,

    //signal to MMU
    output reg[`RegBus]           mem_addr_o_,
    output wire                   mem_we_o,
    output reg[`RegBus]           mem_data_o,
    output reg                    mem_ce_o,
    output reg[3:0]               mem_sel_o,
    output reg                    addr_sel,
    
    // to ctrl
    output reg                    stallreq_o
);

reg mem_we;
assign mem_we_o = mem_we;

always @* begin // ** needs extending **
    if (rst == `RstEnable) begin
        wreg_o  <= `WriteDisable;
        wd_o    <= `NOPRegAddr;
        wdata_o <= `ZeroWord;
        mem_addr_o_ <= `ZeroWord;
        mem_we <= `WriteDisable;
        mem_sel_o <= 4'b0000;
        mem_data_o <= `ZeroWord;
        mem_ce_o <= `ChipDisable;
        addr_sel <= 1'b0;
        stallreq_o <= `StallDisable;
    end else begin
        wreg_o  <= wreg_i;
        wd_o    <= wd_i;
        wdata_o <= wdata_i;
        
        mem_addr_o_ <= `ZeroWord;
        mem_we <= `WriteDisable;
        mem_sel_o <= 4'b1111;
        mem_ce_o <= `ChipDisable;
        addr_sel <= 1'b0;
        stallreq_o <= `StallDisable;

        case (aluop_i)
            `EXE_LB_OP: begin
                mem_addr_o_ <= mem_addr_i;
                mem_we <= `WriteDisable;
                mem_ce_o <= `ChipEnable;
                addr_sel <= 1'b1;
                stallreq_o <= `StallEnable;
                case (mem_addr_i[1:0])  // TODO endian!
                    2'b00: begin
                        wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                        mem_sel_o <= 4'b1000;
                    end
                    2'b01: begin
                        wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                        mem_sel_o <= 4'b0100;
                    end
                    2'b10: begin
                        wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                        mem_sel_o <= 4'b0010;
                    end
                    2'b11: begin
                        wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                        mem_sel_o <= 4'b0001;
                    end
                endcase 
            end
            default: begin
            end
        endcase
    end
end

// assign stallreq_o = `StallDisable;
// always @* begin
//     if (rst == `RstEnable)
//         stallreq_o <= `StallDisable;
//     else
//         stallreq_o <= `StallDisable;
// end

endmodule // mem
