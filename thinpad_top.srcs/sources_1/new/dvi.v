`timescale 1ns / 1ps
//
// WIDTH: bits in register hdata & vdata
// HSIZE: horizontal size of visible field 
// ADDRWID: pixel address width of visible field 
// ADDRMAX: max pixel address of visible field 
// HFP: horizontal front of pulse
// HSP: horizontal stop of pulse
// HMAX: horizontal max size of value
// VSIZE: vertical size of visible field 
// VFP: vertical front of pulse
// VSP: vertical stop of pulse
// VMAX: vertical max size of value
// HSPP: horizontal synchro pulse polarity (0 - negative, 1 - positive)
// VSPP: vertical synchro pulse polarity (0 - negative, 1 - positive)
//
module dvi
#(parameter WIDTH = 0, ADDRWID = 0, ADDRMAX = 0, HSIZE = 0, HFP = 0, HSP = 0, HMAX = 0, VSIZE = 0, VFP = 0, VSP = 0, VMAX = 0, HSPP = 0, VSPP = 0)
(
    input wire clk,
    output wire hsync,
    output wire vsync,
    output reg [WIDTH - 1:0]  hdata,
    output reg [WIDTH - 1:0]  vdata,
    output reg [ADDRWID - 1:0] addr, // valid address
    output wire data_enable
);

// init
initial begin
    hdata <= 0;
    vdata <= 0;
    addr  <= 0;
end

// hdata
always @ (posedge clk) begin
    if (hdata == (HMAX - 1))
        hdata <= 0;
    else
        hdata <= hdata + 1;
end

// vdata
always @ (posedge clk) begin
    if (hdata == (HMAX - 1)) begin
        if (vdata == (VMAX - 1))
            vdata <= 0;
        else
            vdata <= vdata + 1;
    end
end

// addr
always @ (posedge clk) begin
    if (addr == (ADDRMAX - 1)) begin
        addr <= 0;
    end else begin
        addr <= data_enable ? addr + 1 : addr;
    end
end

// hsync & vsync & blank
assign hsync = ((hdata >= HFP) && (hdata < HSP)) ? HSPP : !HSPP;
assign vsync = ((vdata >= VFP) && (vdata < VSP)) ? VSPP : !VSPP;
assign data_enable = ((hdata < HSIZE) & (vdata < VSIZE));

endmodule