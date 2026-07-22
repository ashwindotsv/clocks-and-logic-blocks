`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:31:04
// Design Name: 
// Module Name: processing_element
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

(* use_dsp = "yes" *)
module processing_element #(parameter Pixel_Width=8, Weight_Width = 8,Acc_Width = 32)
    (
    output reg signed [Acc_Width-1:0] PSum_Out,
    output reg [Pixel_Width-1:0] pixel_pass,
    output reg valid_out,
    input signed [Weight_Width-1:0] weight_in,
    input [Pixel_Width-1:0] pixel_in,
    input signed [Acc_Width-1:0] PSum_In,
    input valid_in,load_weight,
    input clk,RSTn,flush
    );
    
    reg signed [Weight_Width-1:0] weight_reg; 
    wire signed [Pixel_Width:0] pixel_ext;
    assign pixel_ext = $signed({1'b0, pixel_in});
   
    always @(posedge clk or negedge  RSTn)
    begin
        if(~RSTn)
        begin
            PSum_Out <= 0;
            pixel_pass <= 0;
            weight_reg <= 0;
            valid_out <= 0;
        end 
        else if (flush) 
        begin
            valid_out  <= 1'b0;
            pixel_pass <= {Pixel_Width{1'b0}};
            PSum_Out   <= {Acc_Width{1'b0}};
        end
        else if(load_weight)
            begin
                weight_reg <= weight_in;
                valid_out <= 1'b0;
            end
            
            else if(valid_in)
            begin
                PSum_Out   <= PSum_In + (weight_reg * pixel_ext);
                pixel_pass <= pixel_in;
                valid_out <= 1'b1;
            end
            else
            begin   
                valid_out <= 1'b0;
                pixel_pass <= {Pixel_Width{1'b0}};
            end
    end
endmodule

