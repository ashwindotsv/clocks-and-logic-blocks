`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 21:00:50
// Design Name: 
// Module Name: Pooling
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

module max_pool2x2 #(parameter DATA_WIDTH = 8)
(
    output reg valid_out,
    output reg [DATA_WIDTH-1:0] pool_out,
    input clk, RSTn, valid_in,
    input [DATA_WIDTH-1:0] pix00,   
    input [DATA_WIDTH-1:0] pix01,   
    input [DATA_WIDTH-1:0] pix10,   
    input [DATA_WIDTH-1:0] pix11 
    
);

    // comparator tree: compare row-wise first, then combine
    // this is 2 levels of compares instead of 3 sequential ones,
    // so it's faster and maps cleanly onto FPGA LUTs
    wire [DATA_WIDTH-1:0] max_top = (pix00 > pix01) ? pix00 : pix01;
    wire [DATA_WIDTH-1:0] max_bot = (pix10 > pix11) ? pix10 : pix11;
    wire [DATA_WIDTH-1:0] max_all = (max_top > max_bot) ? max_top : max_bot;

    always @(posedge clk or negedge RSTn)
    begin
        if (~RSTn)
        begin
            pool_out  <= 0;
            valid_out <= 0;
        end 
        else 
        begin
            valid_out <= valid_in;
            if (valid_in)
                pool_out <= max_all;
        end
    end

endmodule