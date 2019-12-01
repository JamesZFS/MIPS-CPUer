module mmu(
    // from if
    input wire                  cpu_clk,
    input wire                  if_ce_i,
    input wire[31:0]            if_addr_i,  // pc

    //from mem
    input wire[31:0]            mem_addr_i,
    input wire                  mem_we_i,
    input wire[31:0]            mem_data_i,
    input wire                  mem_ce_i,
    input wire[3:0]             mem_sel_i,

    // to mem
	output wire[31:0]           data_o,
    // to if-id
    output wire[31:0]           inst_o,

    // ** inout with BaseRam
    inout wire[31:0]            base_ram_data, //BaseRAM数据，低8位与CPLD串口控制器共享

    // output to BaseRAM
    output wire[19:0]           base_ram_addr, //BaseRAM地址
    output reg                  base_ram_ce_n, //BaseRAM片选，低有效
    output reg                  base_ram_oe_n, //BaseRAM读使能，低有效
    output reg                  base_ram_we_n, //BaseRAM写使能，低有效
    output reg[3:0]             base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0

    // inout with ExtRAM
    inout wire[31:0]            ext_ram_data,  //ExtRAM数据

    // to ExtRAM
    output wire[19:0]           ext_ram_addr,  //ExtRAM地址
    output reg                  ext_ram_ce_n,  //ExtRAM片选，低有效
    output reg                  ext_ram_oe_n,  //ExtRAM读使能，低有效
    output reg                  ext_ram_we_n,  //ExtRAM写使能，低有效
    output reg[3:0]             ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0

    //CPLD串口控制器信号
    output reg                  uart_rdn,         //读串口信号，低有效
    output reg                  uart_wrn,         //写串口信号，低有效

    input wire                  uart_dataready,    //串口数据准备好
    input wire                  uart_tbre,         //发送数据标志
    input wire                  uart_tsre,         //数据发送完毕标志

    // to blk ram
    output reg                  blk_ram_we,
    output wire[18:0]           blk_ram_waddr,
    output reg[7:0]             blk_ram_wdata,

    // from mem/wb
    input wire                  wstate_i,

    // to ctrl
    output reg                  stallreq_o,


    // flash control
    input wire                  flash_clk,
    input wire                  flash_rst,

    output reg[22:0]            flash_a,       //Flash地址，a0仅在8bit模式有效，16bit模式无意义  8MB in total
    inout  wire[15:0]           flash_d,       //Flash数据
    output reg                  flash_ce_n,    //Flash片选信号，低有效
    output reg                  flash_oe_n     //Flash读使能信号，低有效
);


reg[31:0] inner_base_ram_data;
reg[31:0] inner_ext_ram_data;

wire[15:0] mem_addr_hi = mem_addr_i[31:16];
wire mem_access_base_ram  = (mem_ce_i == `ChipEnable) && (16'h8000 <= mem_addr_hi && mem_addr_hi < 16'h8040);  // if memory is accessing baseram ?
wire mem_access_ext_ram   = (mem_ce_i == `ChipEnable) && (16'h8040 <= mem_addr_hi && mem_addr_hi < 16'h8080); // if memory is accessing extram ?
wire mem_access_blk_ram   = (mem_ce_i == `ChipEnable) && (16'hA000 <= mem_addr_hi && mem_addr_hi < 16'hA008); // if accessing block memory ?
wire mem_access_uart_data = (mem_ce_i == `ChipEnable) && (mem_addr_i == 32'hBFD003F8); // serial data
wire mem_access_uart_stat = (mem_ce_i == `ChipEnable) && (mem_addr_i == 32'hBFD003FC); // serial stat


assign base_ram_data = inner_base_ram_data;
assign ext_ram_data = inner_ext_ram_data; 

assign inst_o = if_ce_i == `ChipEnable ? base_ram_data : `ZeroWord;

assign data_o = mem_access_uart_stat ? {30'b0, uart_dataready, uart_tbre & uart_tsre} :
                mem_access_uart_data ? {32{ base_ram_data[7:0] }} :
                mem_access_ext_ram ? ext_ram_data :
                mem_access_base_ram ? base_ram_data : `ZeroWord;  // if disable


assign ext_ram_addr = flash_to_ext_ram ? flash_a[21:2] : mem_addr_i[21:2]; // minus 0x80400000 then div 4
assign blk_ram_waddr = mem_addr_i[18:0]; // each block ram unit is an 8-bit color
assign base_ram_addr = flash_to_base_ram ? flash_a[21:2] :
                       mem_access_base_ram ? mem_addr_i[21:2] :  // minus 0x80000000 then div 4
                       if_addr_i[21:2];  // pc access baseram

always @(*) begin // handle ext ram alone

    ext_ram_ce_n <= `RAMDisable;
    ext_ram_oe_n <= `RAMDisable;
    ext_ram_we_n <= `RAMDisable;
    ext_ram_be_n <= 4'b0000;
    inner_ext_ram_data <= 32'bz;

    if (flash_to_ext_ram) begin // write from flash to extram
        ext_ram_ce_n <= `RAMEnable;
        ext_ram_oe_n <= `RAMDisable;
        ext_ram_we_n <= flash_clk; // first disable then enable
        // ext_ram_we_n <= `RAMEnable;
        case (flash_a[1]) // mask only two bytes
            0: ext_ram_be_n <= 4'b1100;
            1: ext_ram_be_n <= 4'b0011;
        endcase
        inner_ext_ram_data <= {32{flash_d}};
        
    end else if (mem_access_ext_ram) begin
        ext_ram_ce_n <= `RAMEnable;
        // read or write?
        if (mem_we_i == `WriteDisable) begin // read ext ram
            ext_ram_we_n <= `RAMDisable;
            ext_ram_oe_n <= `RAMEnable;
            inner_ext_ram_data <= 32'bz;
        end else begin // write ext ram
            // ext_ram_we_n <= `RAMEnable;
            ext_ram_be_n <= mem_sel_i;
            ext_ram_we_n <= (wstate_i == 0) ? `RAMDisable : cpu_clk; // 1st cpu_clk disable, 2nd cpu_clk enable
            ext_ram_oe_n <= `RAMDisable;
            inner_ext_ram_data <= mem_data_i;
        end
    end

end

always @(*) begin // handle block ram alone

    if (mem_access_blk_ram && mem_we_i == `WriteEnable) begin
        blk_ram_we  <= (wstate_i == 0) ? `BRAMDisable : `BRAMEnable; // 1st clk disable, 2nd clk enable
        blk_ram_wdata <= mem_data_i[7:0];
    end else begin // read is not allowed
        blk_ram_we  <= `BRAMDisable;
        blk_ram_wdata <= 8'bz;
    end
    
end

always @(*) begin // ** handle bus conflicts here 

    stallreq_o <= `StallDisable;
    base_ram_ce_n <= `RAMDisable;
    base_ram_we_n <= `RAMDisable;
    base_ram_oe_n <= `RAMDisable;
    base_ram_be_n <= 4'b0000;
    inner_base_ram_data <= 32'bz;
    uart_rdn <= `UARTDisable;
    uart_wrn <= `UARTDisable;

    if (flash_to_base_ram) begin // write from flash to baseram
        base_ram_ce_n <= `RAMEnable;
        base_ram_oe_n <= `RAMDisable;
        base_ram_we_n <= flash_clk; // first disable then enable
        // base_ram_we_n <= `RAMEnable;
        case (flash_a[1]) // mask only two bytes
            0: base_ram_be_n <= 4'b1100;
            1: base_ram_be_n <= 4'b0011;
        endcase
        inner_base_ram_data <= {32{flash_d}};

    end else if (mem_access_base_ram) begin
        // !!
        stallreq_o <= `StallEnable;
        base_ram_ce_n <= `RAMEnable;
        if (mem_we_i == `WriteDisable) begin // read base ram
            base_ram_we_n <= `RAMDisable;
            base_ram_oe_n <= `RAMEnable;
            inner_base_ram_data <= 32'bz;
        end else begin  // write base ram
            // base_ram_we_n <= `RAMEnable;
            base_ram_be_n <= mem_sel_i;
            base_ram_we_n <= (wstate_i == 0) ? `RAMDisable : cpu_clk; // 1st clk disable, 2nd clk enable
            base_ram_oe_n <= `RAMDisable;
            inner_base_ram_data <= mem_data_i;
        end
    end else if (mem_access_uart_data) begin
        // !!
        stallreq_o <= `StallEnable;
        if (mem_we_i == `WriteDisable) begin // read uart
            uart_rdn <= `UARTEnable;
            uart_wrn <= `UARTDisable;
            inner_base_ram_data <= 32'bz;
        end else begin
            uart_rdn <= `UARTDisable;
            // uart_wrn <= clk;  // * write concurrently with clk
            uart_wrn <= (wstate_i == 0) ? `UARTDisable : cpu_clk; // 1st clk disable, 2nd clk enable
            inner_base_ram_data <= mem_data_i;
        end
        // uart stat already returned, no need to stall
    end else if (if_ce_i == `ChipEnable) begin // read pc inst
        // ok
        base_ram_ce_n <= `RAMEnable;
        base_ram_we_n <= `RAMDisable;
        base_ram_oe_n <= `RAMEnable;
        // base ram addr already returned
    end

end



/* =========== Flash code begin =========== */

// 当按住 flash_rst 时，从 Flash 的 0x000000 - 0x3FFFFF 加载程序到 baseram 
// 从 Flash 的 0x400000 - 0x7FFFFF 加载数据到 extram

always @(posedge flash_clk) begin  // generate flash control signals
    if (flash_rst == `RstDisable) begin
        flash_ce_n <= `FlashDisable;
        flash_oe_n <= `FlashDisable;
        flash_a <= 23'b0;
    end else begin // flash is on
        flash_ce_n <= `FlashEnable;
        flash_oe_n <= `FlashEnable;
        flash_a <= flash_a + 2; // read 2 bytes per clk
    end
end

wire flash_to_base_ram = (flash_ce_n == `FlashEnable && flash_oe_n == `FlashEnable) && (flash_a[22] == 0);  // if flash should map to baseram ?
wire flash_to_ext_ram  = (flash_ce_n == `FlashEnable && flash_oe_n == `FlashEnable) && (flash_a[22] == 1); // if flash should map to extram ?

/* =========== Flash code end =========== */



endmodule // inst_ram