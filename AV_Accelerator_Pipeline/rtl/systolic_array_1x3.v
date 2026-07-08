`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:39:55
// Design Name: 
// Module Name: systolic_array_1x3
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


module systolic_array_1x3 #(parameter Pixel_Width=8, Weight_Width = 8,Acc_Width = 32)
    (
        output signed [Acc_Width-1:0] PSum_Out_1x3,
        output valid_out_1x3,
        input signed [Weight_Width-1:0] weight_in0, weight_in1, weight_in2,
        input [Pixel_Width-1:0] pixel_in_1x3,
        input signed [Acc_Width-1:0] PSum_In_1x3,
        input valid_in_1x3,load_weight,
        input clk,RSTn
    );
    
    wire [Pixel_Width-1:0] pix_01,pix_02;

    wire signed [Acc_Width-1:0] psum_01,psum_02;

    wire valid_01, valid_02;
    
    wire [Pixel_Width-1:0] unused_pix;
    
    reg signed [Acc_Width-1:0] psum_01_reg, psum_02_reg;
    reg valid_01_reg, valid_02_reg;
    
    always @(posedge clk or negedge RSTn) begin
        if (~RSTn) 
        begin
            psum_01_reg  <= 0;
            psum_02_reg  <= 0;
            valid_01_reg <= 1'b0;
            valid_02_reg <= 1'b0;
        end 
        else 
        begin
            psum_01_reg  <= psum_01;
            psum_02_reg  <= psum_02;
            valid_01_reg <= valid_01;
            valid_02_reg <= valid_02;
        end
    end
    
    
    processing_element #(8,8,32) DUT_PE_1
    (
        .PSum_Out(psum_01),
        .pixel_pass(pix_01),
        .load_weight(load_weight),
        .valid_in(valid_in_1x3),.valid_out(valid_01),
        .weight_in(weight_in0),.pixel_in(pixel_in_1x3),
        .PSum_In(PSum_In_1x3),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_2
    (
        .PSum_Out(psum_02),
        .pixel_pass(pix_02),        
        .load_weight(load_weight),
        .valid_in(valid_01),.valid_out(valid_02),
        .weight_in(weight_in1),.pixel_in(pix_01),
        .PSum_In(psum_01),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_3
    (
        .PSum_Out(PSum_Out_1x3),
        .pixel_pass(unused_pix),        
        .load_weight(load_weight),
        .valid_in(valid_02),.valid_out(valid_out_1x3),
        .weight_in(weight_in2),.pixel_in(pix_02),
        .PSum_In(psum_02),
        .clk(clk),.RSTn(RSTn)  
    );
    
endmodule

