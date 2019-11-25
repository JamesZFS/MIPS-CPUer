module mem(
    input wire      rst,

    // singals from ex
    input wire                    wreg_i,
    input wire[`RegAddrBus]       wd_i,
    input wire[`RegBus]           wdata_i,

    input wire[`AluOpBus]         aluop_i,
    input wire[`RegBus]           mem_addr_i,
    input wire[`RegBus]           reg2_i,

    // signals to wb (and forward to id)
    output reg                    wreg_o,
    output reg[`RegAddrBus]       wd_o,
    output reg[`RegBus]           wdata_o,

    //signal to MMU
    output reg[`RegBus]           mem_addr_o,
    output wire                   mem_we_o,
    output reg[`RegBus]           mem_data_o,
    output reg                    mem_ce_o,
    output reg[3:0]               mem_sel_o,

    //signal from mmu
    input wire[`RegBus]           mem_data_i
);

reg mem_we;
assign mem_we_o = mem_we;

always @* begin
    if (rst == `RstEnable) begin
        wreg_o  <= `WriteDisable;
        wd_o    <= `NOPRegAddr;
        wdata_o <= `ZeroWord;

        mem_addr_o <= `ZeroWord;
        mem_we <= `WriteDisable;
        mem_sel_o <= 4'b0000;
        mem_data_o <= `ZeroWord;
        mem_ce_o <= `ChipDisable;

    end else begin
        wreg_o  <= wreg_i;
        wd_o    <= wd_i;
        wdata_o <= wdata_i;

        mem_addr_o <= `ZeroWord;
        mem_we <= `WriteDisable;
        mem_sel_o <= 4'b1111;
        mem_data_o <= `ZeroWord;
        mem_ce_o <= `ChipDisable;

        case (aluop_i)
            `EXE_LB_OP: begin
                mem_addr_o <= mem_addr_i;
                mem_we <= `WriteDisable;
                mem_ce_o <= `ChipEnable;
                case (mem_addr_i[1:0])  // TODO endian!
                    2'b00: begin
                        wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                        mem_sel_o <= 4'b1000;
                    end
                    2'b01: begin
                        wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                        mem_sel_o <= 4'b0100;
                    end
                    2'b10: begin
                        wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                        mem_sel_o <= 4'b0010;
                    end
                    2'b11: begin
                        wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                        mem_sel_o <= 4'b0001;
                    end
                endcase
            end
            default:;
        endcase
    end
end


endmodule // mem
