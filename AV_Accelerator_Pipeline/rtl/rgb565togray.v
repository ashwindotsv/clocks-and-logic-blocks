`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 07:50:04
// Design Name: 
// Module Name: rgb565togray
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module rgb565togray #(parameter DATA_WIDTH = 8)
(   
    output reg valid_out,
    output reg  [DATA_WIDTH-1:0]   gray_out,
    input  clk, RSTn,valid_in,
    input  wire [15:0]pixel_in   // packed RGB565: {R[4:0], G[5:0], B[4:0]}
   
);

    // unpack RGB565
    wire [4:0] r5 = pixel_in[15:11];
    wire [5:0] g6 = pixel_in[10:5];
    wire [4:0] b5 = pixel_in[4:0];

    // expand each channel to 8 bits by replicating the top bits into
    // the missing low bits (standard RGB565->RGB888 trick). straight
    // left-shifting would leave the low bits as zero and darken the
    // image slightly; replication keeps full-white staying full-white.
    wire [7:0] r8 = {r5, r5[4:2]};   // 5 bits -> 8 bits
    wire [7:0] g8 = {g6, g6[5:4]};   // 6 bits -> 8 bits
    wire [7:0] b8 = {b5, b5[4:2]};   // 5 bits -> 8 bits

    // standard luminance weights: Y = 0.299R + 0.587G + 0.114B
    // scaled to 8-bit fixed point (x256) and rounded:
    //   0.299 * 256 = 77
    //   0.587 * 256 = 150
    //   0.114 * 256 = 29
    
    wire [16:0] weighted_sum = (r8 * 8'd77) + (g8 * 8'd150) + (b8 * 8'd29);

    // divide by 256 via right-shift to undo the fixed-point scaling
    wire [DATA_WIDTH-1:0] gray_calc = weighted_sum[15:8];

    always @(posedge clk or negedge RSTn) 
    begin
        if (!RSTn) 
        begin
            gray_out  <= 0;
            valid_out <= 0;
        end 
        else 
        begin
            valid_out <= valid_in;
            if (valid_in)
                gray_out <= gray_calc;
        end
    end

endmodule
