`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2026 10:17:48
// Design Name: 
// Module Name: line_buffer
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

module line_buffer #(parameter IMG_WIDTH = 640)
    (
        output reg [7:0] pixel_out,
        output reg buffer_full,
        input [7:0]pixel_in,
        input pix_valid,
        input clk,RSTn
    );
    
    reg [7:0] lbuf [0:IMG_WIDTH-1];
    reg [$clog2(IMG_WIDTH)-1:0] ptr;
    
    always @(posedge clk , negedge RSTn)
    begin
        if (~RSTn)
        begin 
            pixel_out <= 0;
            ptr <= 0;
            buffer_full <=0;
        end 
        else 
        begin
            if(pix_valid)
            begin
                pixel_out <= lbuf[ptr];
                lbuf[ptr] <= pixel_in;
                if (ptr == IMG_WIDTH-1)
                begin
                    ptr <= 0;
                    buffer_full <= 1;
                end
                else
                begin
                    ptr <= ptr +1;
                end
            end
        end 
    end
endmodule

module line_buf_tb;
    
        wire [7:0] pixel_out;
        wire buffer_full;
        reg [7:0]pixel_in;
        reg pix_valid;
        reg clk,RSTn;
        
     line_buffer #(5) dut (
    .pixel_out(pixel_out),
    .buffer_full(buffer_full),
    .pixel_in(pixel_in),
    .pix_valid(pix_valid),
    .clk(clk),
    .RSTn(RSTn)
);


endmodule 