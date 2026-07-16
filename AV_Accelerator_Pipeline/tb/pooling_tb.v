`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.07.2026 07:26:57
// Design Name: 
// Module Name: pooling_tb
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

module max_pool2x2_tb;

    parameter DATA_WIDTH = 8;
     
    wire valid_out;
    wire [DATA_WIDTH-1:0]   pool_out;
    reg  clk, RSTn, valid_in;
    reg [DATA_WIDTH-1:0] pix00, pix01, pix10,  pix11;
    
    max_pool2x2 #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .clk(clk),
        .RSTn(RSTn),
        .valid_in(valid_in),
        .pix00(pix00),
        .pix01(pix01),
        .pix10(pix10),
        .pix11(pix11),
        .valid_out(valid_out),
        .pool_out(pool_out)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;
    initial 
    begin

        // Initialize inputs
        RSTn = 0;clk = 0;valid_in = 0;
        pix00 = 0;pix01 = 0;pix10 = 0;pix11 = 0;
        #20;
        RSTn = 1;

      
        @(posedge clk);
        valid_in = 1;
        pix00 = 8'd5;
        pix01 = 8'd8;
        pix10 = 8'd3;
        pix11 = 8'd1;
        @(posedge clk);
        pix00 = 8'd10;
        pix01 = 8'd25;
        pix10 = 8'd17;
        pix11 = 8'd9;
        @(posedge clk);
        pix00 = 8'd100;
        pix01 = 8'd50;
        pix10 = 8'd200;
        pix11 = 8'd150;
        @(posedge clk);
        pix00 = 8'd255;
        pix01 = 8'd0;
        pix10 = 8'd127;
        pix11 = 8'd64;
        @(posedge clk);
        valid_in = 0;
        #30;
        $finish;

    end

    // Monitor signals
    initial begin
        $display("---------------------------------------------------------------");
        $display("Time\tValid_in\tPixels\t\t\t\tValid_out\tPool");
        $display("---------------------------------------------------------------");

        $monitor("%0t\t%b\t\t[%0d %0d %0d %0d]\t%b\t\t%0d",
                 $time,
                 valid_in,
                 pix00, pix01, pix10, pix11,
                 valid_out,
                 pool_out);
    end

endmodule