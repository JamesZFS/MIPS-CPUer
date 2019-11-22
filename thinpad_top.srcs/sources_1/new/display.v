module DVI_display(
    input wire clk,
    input wire rst,

    input wire[`HVDataBus]  x,
    input wire[`HVDataBus]  y,

    output reg[2:0] r,   // red pixel, 3bits
    output reg[2:0] g,   // green pixel, 3bits
    output reg[1:0] b,    // blue pixel, 2bits

    output wire[1:0] debug
);

reg[1:0] state;
assign debug = state;

always @(posedge clk or posedge rst) begin
    if (rst == `RstEnable) begin
        state <= 3;
    end else begin // clk
        state <= state >= 2 ? 0 : state + 1;
    end
end

always @(x or y or state) begin
    case (state)
        0: begin
            r <= x < 266 ?               `RED : `BLACK;
            g <= 266 <= x && x < 532 ? `GREEN : `BLACK;
            b <= 532 <= x ?             `BLUE : `BLACK;
        end

        1: begin
            g <= x < 266 ?            `GREEN : `BLACK;
            b <= 266 <= x && x < 532 ? `BLUE : `BLACK;
            r <= 532 <= x ?             `RED : `BLACK;
        end

        2: begin
            b <= x < 266 ?            `BLUE : `BLACK;
            r <= 266 <= x && x < 532 ? `RED : `BLACK;
            g <= 532 <= x ?          `GREEN : `BLACK;
        end

        default: begin // error
            r <= `BLACK;
            g <= `BLACK;
            b <= `BLACK; 
        end
    endcase
end


endmodule // DVI_display