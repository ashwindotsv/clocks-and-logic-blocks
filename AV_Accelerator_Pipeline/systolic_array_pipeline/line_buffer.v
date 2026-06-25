`timescale 1ns / 10ps
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
                    buffer_full <=0;
                end
            end
            else 
            begin
                 pixel_out <= pixel_out;
                 buffer_full <=0;
            end
        end 
    end
endmodule

module line_buf_tb;
    
        wire [7:0] pixel_out;
        wire buffer_full;
        reg [7:0]pixel_in;
        reg pix_valid, clk, RSTn;
        
     line_buffer #(5) DUT_buf (
    .pixel_out(pixel_out),
    .buffer_full(buffer_full),
    .pixel_in(pixel_in),
    .pix_valid(pix_valid),
    .clk(clk),
    .RSTn(RSTn)
    );
    
    task buffer;
        input [7:0]pix_in;
        input pix_val;
        begin
            pixel_in  = pix_in;
            pix_valid = pix_val;
            #10;
            if(pix_valid)
            begin
                $display("OUTPUT PIXEL : %d",pixel_out);
            end
        end
    endtask

    initial 
        begin
            clk = 0; RSTn = 0; pix_valid = 0; pixel_in =0;
        end
    
    always #5 clk = ~clk;
    
    initial 
    begin
       #20 RSTn = 1;
       buffer(10,1);
       buffer(20,1);
       buffer(30,1);
       buffer(40,1);
       buffer(50,1);
       buffer(60,1);
       buffer(70,1);
       buffer(80,1);
       buffer(90,1);
       buffer(10,0);
       buffer(20,0);
       buffer(30,0);
       buffer(10,1);
       buffer(20,1);
       buffer(30,1);
       buffer(40,1);
       buffer(50,0);
       buffer(60,0);
       buffer(70,1);
       buffer(80,0);
       buffer(90,1);
       buffer(10,0);
       buffer(20,0);
       buffer(30,0);
       $finish;
    end
    
endmodule 