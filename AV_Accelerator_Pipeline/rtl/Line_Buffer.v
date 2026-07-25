`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:20:03
// Design Name: 
// Module Name: Line_Buffer
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


module Line_buffer #(parameter IMG_WIDTH = 640)
    (
        output reg [7:0] pixel_out,
        output reg buffer_full,
        input [7:0]pixel_in,
        input pix_valid,
        input clk,RSTn
    );
    
    (* ram_style = "block" *) reg [7:0] lbuf [0:IMG_WIDTH-1];    
    reg [$clog2(IMG_WIDTH)-1:0] wr_ptr;
    
    always @(posedge clk , negedge RSTn)
    begin
        if (~RSTn)
        begin 
            pixel_out <= 0;
            wr_ptr <= 0;
            buffer_full <=0;
        end 
        else 
        begin
            if(pix_valid)
            begin
                pixel_out <= lbuf[wr_ptr];
                lbuf[wr_ptr] <= pixel_in;
                if (wr_ptr == IMG_WIDTH-1)
                begin
                    wr_ptr <= 0;
                    buffer_full <= 1;
                end
                else
                begin
                    wr_ptr <= wr_ptr +1;
                    buffer_full <=0;
                end
            end
            else 
            begin
                 buffer_full <=0;
            end
        end 
    end
endmodule
