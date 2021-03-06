`default_nettype none

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信号
    output wire uart_rdn,         //读串口信号，低有效
    output wire uart_wrn,         //写串口信号，低有效
    input wire uart_dataready,    //串口数据准备好
    input wire uart_tbre,         //发送数据标志
    input wire uart_tsre,         //数据发送完毕标志

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire[22:0]flash_a,       //Flash地址，a0仅在8bit模式有效，16bit模式无意义  8MB in total
    inout  wire[15:0]flash_d,       //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //USB 控制器信号，参考 SL811 芯片手册
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参考 DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M, clk_30M, clk_40M;
pll_example clock_gen 
 (
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  .clk_out3(clk_30M),
  .clk_out4(clk_40M),
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked), // 锁定输出，"1"表示时钟稳定，可作为后级电路复位
 // Clock in ports
  .clk_in1(clk_50M) // 外部时钟输入
 );

reg reset_of_clk10M;
// 异步复位，同步释放
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

always@(posedge clk_10M or posedge reset_of_clk10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else begin
        // Your Code
    end
end

// 不使用内存、串口时，禁用其使能信号
// assign base_ram_ce_n = `RAMDisable;
// assign base_ram_oe_n = `RAMDisable;
// assign base_ram_we_n = `RAMDisable;
// assign base_ram_be_n = `RAMEnable; // enable all bytes

// assign ext_ram_ce_n = `RAMDisable;
// assign ext_ram_oe_n = `RAMDisable;
// assign ext_ram_we_n = `RAMDisable;
// assign ext_ram_be_n = `RAMEnable;

// assign uart_rdn = `UARTDisable;
// assign uart_wrn = `UARTDisable;

// 数码管连接关系示意图，dpy1同理
// p=dpy0[0] // ---a---
// c=dpy0[1] // |     |
// d=dpy0[2] // f     b
// e=dpy0[3] // |     |
// b=dpy0[4] // ---g---
// a=dpy0[5] // |     |
// f=dpy0[6] // e     c
// g=dpy0[7] // |     |
//           // ---d---  p

// 7段数码管译码器演示，将number用16进制显示在数码管上面
reg[7:0] lcd_number = 0;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(lcd_number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(lcd_number[7:4])); //dpy1是高位数码管

//直连串口接收发送演示，从直连串口收到的数据再发送出去
wire [7:0] ext_uart_rx;
reg  [7:0] ext_uart_buffer, ext_uart_tx;
wire ext_uart_ready, ext_uart_busy;
reg ext_uart_start, ext_uart_avai;

async_receiver #(.ClkFrequency(50000000),.Baud(9600)) //接收模块，9600无检验位
    ext_uart_r(
        .clk(clk_50M),                       //外部时钟信号
        .RxD(rxd),                           //外部串行信号输入
        .RxD_data_ready(ext_uart_ready),  //数据接收到标志
        .RxD_clear(ext_uart_ready),       //清除接收标志
        .RxD_data(ext_uart_rx)             //接收到的一字节数据
    );
    
always @(posedge clk_50M) begin //接收到缓冲区ext_uart_buffer
    if(ext_uart_ready)begin
        ext_uart_buffer <= ext_uart_rx;
        ext_uart_avai <= 1;
    end else if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_avai <= 0;
    end
end
always @(posedge clk_50M) begin //将缓冲区ext_uart_buffer发送出去
    if(!ext_uart_busy && ext_uart_avai)begin 
        ext_uart_tx <= ext_uart_buffer;
        ext_uart_start <= 1;
    end else begin 
        ext_uart_start <= 0;
    end
end

async_transmitter #(.ClkFrequency(50000000),.Baud(9600)) //发送模块，9600无检验位
    ext_uart_t(
        .clk(clk_50M),                  //外部时钟信号
        .TxD(txd),                      //串行信号输出
        .TxD_busy(ext_uart_busy),       //发送器忙状态指示
        .TxD_start(ext_uart_start),    //开始发送信号
        .TxD_data(ext_uart_tx)        //待发送的数据
    );

/* =========== Demo code end =========== */


/* =========== Video memory code begin =========== */

//图像输出演示，分辨率800x600@75Hz，像素时钟为50MHz
assign video_clk = clk_50M;

// from mmu to blk_ram  TODO
wire       blk_ram_we;
wire[18:0] blk_ram_waddr;
wire[7:0]  blk_ram_wdata;

// from bram to top
wire[7:0]  blk_ram_rdata;

// from dvi gen to bram
wire[11:0] dvi_x;
wire[11:0] dvi_y;
wire[18:0] blk_ram_raddr;

// WIDTH ADDRWID ADDRMAX HSIZE  HFP  HSP  HMAX VSIZE  VFP  VSP VMAX HSPP VSPP
dvi #(12,     19, 480000,  800, 856, 976, 1040,  600, 637, 643, 666,   1,   1) dvi800x600at75_gen (
    // in:
    .clk(video_clk), 
    // out:
    .hdata(dvi_x), //横坐标
    .vdata(dvi_y), //纵坐标
    .addr(blk_ram_raddr), // address of valid pixel
    .hsync(video_hsync),
    .vsync(video_vsync),
    .data_enable(video_de)
);

blk_mem_gen_0 video_mem_gen(
    // write port in:
    .clka(`CPU_CLK), 
    .wea(blk_ram_we), 
    .addra(blk_ram_waddr), 
    .dina(blk_ram_wdata), 
    // read port in:
    .clkb(video_clk), 
    .addrb(blk_ram_raddr), 
    // read port out:
    .doutb(blk_ram_rdata)
);

assign video_red   = blk_ram_rdata[7:5];
assign video_green = blk_ram_rdata[4:2];
assign video_blue  = blk_ram_rdata[1:0];

/* =========== Video memory code end =========== */


/* ============== Mips32 Pipeline code begin ============== */

// flash control:
// reg[22:0] inner_flash_a = 23'bz;
// assign flash_a = inner_flash_a;     // always read
assign flash_rp_n = `FlashDisable;  // no resetting
assign flash_vpen = `FlashEnable;   // no modifying
assign flash_we_n = `FlashDisable;  // no writing
assign flash_byte_n = `FlashDisable; // use 16bit mode

wire[`InstAddrBus]  inst_addr; // mips to ram
wire                inst_ram_ce;  // mips to ram
wire[31:0]          mem_data;    // ram to mem
wire[31:0]          inst;        // ram to if-id
wire[`RegBus]       debug1;   // ** debug signal
wire[`RegBus]       debug2;   // ** debug signal
wire                mmu_stallreq;
wire                mmu_wstate;  // to mmu

wire flash_rst = touch_btn[1];
wire cpu_rst = touch_btn[1] || touch_btn[0] || ~locked;

//mips.mem->mmu
wire[`RegBus]   mem_addr_o;
wire            mem_we_o;
wire[`RegBus]   mem_data_o;
wire            mem_ce_o;
wire[3:0]       mem_sel_o;

mips mips0(
`ifdef ON_FPGA
    .clk(`CPU_CLK),
`else
    .clk(clock_btn),
`endif
    .rst(cpu_rst),
    // from mmu
    .mmu_mem_data_i(mem_data),
    .ram_inst_i(inst),
    .mmu_stallreq_i(mmu_stallreq),
    .uart_int_i(uart_dataready),

    // to mmu
    .ram_addr_o(inst_addr),
    .ram_ce_o(inst_ram_ce),

    //from mips.mem to mmu
    .mem_addr_o(mem_addr_o),
    .mem_we_o(mem_we_o),
    .mem_data_o(mem_data_o),
    .mem_ce_o(mem_ce_o),
    .mem_sel_o(mem_sel_o),

    .wstate_o(mmu_wstate),

    .debug1_o(debug1),
    .debug2_o(debug2)
);

mmu mmu0(
`ifdef ON_FPGA
    .cpu_clk(`CPU_CLK),
`else
    .cpu_clk(clock_btn),
`endif
    .if_ce_i(inst_ram_ce),
    .if_addr_i(inst_addr),

    // input from mips.mem
    .mem_addr_i(mem_addr_o),
    .mem_we_i(mem_we_o),
    .mem_data_i(mem_data_o),
    .mem_ce_i(mem_ce_o),
    .mem_sel_i(mem_sel_o),

    // to mips
    .data_o(mem_data),
    .inst_o(inst),

    // inout with BaseRAM
    .base_ram_data(base_ram_data),
    // output to BaseRAM
    .base_ram_addr(base_ram_addr),
    .base_ram_ce_n(base_ram_ce_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_we_n(base_ram_we_n),
    .base_ram_be_n(base_ram_be_n),

    // inout with BaseRAM
    .ext_ram_data(ext_ram_data),
    // output to BaseRAM
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_ce_n(ext_ram_ce_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_we_n(ext_ram_we_n),
    .ext_ram_be_n(ext_ram_be_n),

    // to uart
    .uart_rdn(uart_rdn),
    .uart_wrn(uart_wrn),

    // form uart
    .uart_dataready(uart_dataready),
    .uart_tbre(uart_tbre),
    .uart_tsre(uart_tsre),

    // to blk ram
    .blk_ram_we(blk_ram_we),
    .blk_ram_waddr(blk_ram_waddr),
    .blk_ram_wdata(blk_ram_wdata),

    // from mem/wb
    .wstate_i(mmu_wstate),

    // to control
    .stallreq_o(mmu_stallreq),


    // flash control:
    .flash_clk(clk_10M),
    .flash_rst(flash_rst),

    .flash_a(flash_a),
    .flash_d(flash_d),
    .flash_ce_n(flash_ce_n),
    .flash_oe_n(flash_oe_n)
);

/* ============== Mips32 Pipeline code end   ============== */

// ***** debug display *****

reg[15:0] cur_stage = 1;
assign leds = cur_stage;
reg  cur_stop = 0;

`ifdef ON_FPGA

always @(posedge clock_btn) begin
    cur_stop <= !cur_stop;
end

always@(posedge `CPU_CLK) begin
    if (!cur_stop) begin
        lcd_number <= debug1[7:0];
        cur_stage <= debug2[17:2];
    end
end

`else

always@(posedge clock_btn) begin
    lcd_number <= debug1[7:0];
    cur_stage <= debug2[17:2];
end

`endif

endmodule
