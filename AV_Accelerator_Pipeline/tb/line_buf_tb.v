`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:28:38
// Design Name: 
// Module Name: line_buf_tb
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


module line_buf_tb;
    
        wire [7:0] pixel_out;
        wire buffer_full;
        reg [7:0]pixel_in;
        reg pix_valid, clk, RSTn;
        
     Line_buffer #(5) DUT_buf (
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
