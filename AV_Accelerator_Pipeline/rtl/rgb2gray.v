`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 07:18:15
// Design Name: 
// Module Name: rgb2gray
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

module rgb2gray #(parameter DATA_WIDTH = 8)
(
    output reg valid_out,
    output reg  [DATA_WIDTH-1:0]   gray_out,
    input  clk, RSTn, valid_in,
    input  wire [DATA_WIDTH-1:0]   R, G, B
    
);

    //  Y = 0.299R + 0.587G + 0.114B
    // scaled to 8-bit fixed point (x256) and rounded:
    //   0.299 * 256 = 77 | 0.587 * 256 = 150 | 0.114 * 256 = 29
    wire [DATA_WIDTH+9:0] weighted_sum = (R * 8'd77) + (G * 8'd150) + (B * 8'd29);

    // divide by 256 via right-shift to undo the fixed-point scaling
    wire [DATA_WIDTH-1:0] gray_calc = weighted_sum[DATA_WIDTH+7:8];

    always @(posedge clk or negedge RSTn) 
    begin
        if (~RSTn) 
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
