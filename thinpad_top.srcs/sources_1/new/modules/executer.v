
module ex(
    input   wire  rst,
	
    // signal from id
    input wire[`AluOpBus]         aluop_i,
    input wire[`AluSelBus]        alusel_i,
    input wire[`RegBus]           reg1_i,
    input wire[`RegBus]           reg2_i,
    input wire[`RegAddrBus]       wd_i,
    input wire                    wreg_i,	
    
    // result
    output reg                    wreg_o,
    output reg[`RegAddrBus]       wd_o,
    output reg[`RegBus]           wdata_o
);

reg[`RegBus]    reg_result;

always @ * begin    // perform computation
    
    if (rst == `RstEnable) begin
        reg_result <= `ZeroWord;
    end else begin
        case (aluop_i)      // ** case various alu operations **

            `EXE_OR_OP: reg_result <= reg1_i | reg2_i;

            default: reg_result <= `ZeroWord;
            
        endcase
    end

end

always @ * begin    // generate write signal
    if (rst == `RstEnable) begin      //  TODO: block this case or not?
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        wdata_o <= `ZeroWord;
    end else begin
        wd_o <= wd_i;
        wreg_o <= wd_o;
        case (alusel_i)     // alu result selection

            `EXE_RES_LOGIC: wdata_o <= reg_result; 

            default: wdata_o <= `ZeroWord;

        endcase
    end
end


endmodule // ex