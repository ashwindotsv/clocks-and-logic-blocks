`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:52:40
// Design Name: 
// Module Name: Systolic_Array_3x3
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


module Systolic_Array_3x3 #(parameter Pixel_Width=8, Weight_Width = 8,Acc_Width = 32)
    (
        output signed [Acc_Width-1:0] PSum_Out_C1,PSum_Out_C2,PSum_Out_C3,
        output valid_out_3x3,
        input signed [Weight_Width-1:0] weight_in_00, weight_in_01, weight_in_02,
        input signed [Weight_Width-1:0] weight_in_10, weight_in_11, weight_in_12,
        input signed [Weight_Width-1:0] weight_in_20, weight_in_21, weight_in_22,
        input [Pixel_Width-1:0] pixel_in_R1,
        input [Pixel_Width-1:0] pixel_in_R2,
        input [Pixel_Width-1:0] pixel_in_R3,
        input signed [Acc_Width-1:0] PSum_In_3x3,
        input valid_in_3x3,
        input load_weight,
        input clk,RSTn,flush
    );
    //pixel wires
    wire [Pixel_Width-1:0] pix_00_to_01, pix_01_to_02, unused_pix02;
    wire [Pixel_Width-1:0] pix_10_to_11, pix_11_to_12, unused_pix12;
    wire [Pixel_Width-1:0] pix_20_to_21, pix_21_to_22, unused_pix22;
    
    //Partial Sum wires
    wire signed [Acc_Width-1:0] psum_00_to_10, psum_10_to_20;
    wire signed [Acc_Width-1:0] psum_01_to_11, psum_11_to_21;
    wire signed [Acc_Width-1:0] psum_02_to_12, psum_12_to_22;
    wire signed [Acc_Width-1:0] EmptyPSumIN_1, EmptyPSumIN_2;
    
    // valid propagation
    wire valid_00, valid_01, valid_02;
    wire valid_10, valid_11, valid_12;
    wire valid_20, valid_21, valid_22;
    
    wire valid_10_01,valid_11_02;
    wire valid_11_20,valid_21_12;
    
    //PE active if upper and left PE sends valid_out
    assign valid_10_01 = valid_01 && valid_10;
    assign valid_11_02 = valid_11 && valid_02;
    assign valid_11_20 = valid_11 && valid_20;
    assign valid_21_12 = valid_21 && valid_12;
    
    //empty PsumIn 
    assign EmptyPSumIN_1 = 0;
    assign EmptyPSumIN_2 = 0;
    
    //INSTANTIATE 9 PEs
    processing_element #(8,8,32) DUT_PE_00
    (
        .PSum_Out(psum_00_to_10),
        .pixel_pass(pix_00_to_01),
        .load_weight(load_weight),
        .valid_in(valid_in_3x3),
        .valid_out(valid_00),
        .weight_in(weight_in_00),
        .pixel_in(pixel_in_R1),
        .PSum_In(PSum_In_3x3),
        .flush(flush),
        .clk(clk),
        .RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_01
    (
        .PSum_Out(psum_01_to_11),
        .pixel_pass(pix_01_to_02),        
        .load_weight(load_weight),
        .valid_in(valid_00),
        .valid_out(valid_01),
        .weight_in(weight_in_01),
        .pixel_in(pix_00_to_01),
        .PSum_In(EmptyPSumIN_1),
        .clk(clk),.flush(flush),
        .RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_02
    (
        .PSum_Out(psum_02_to_12),
        .pixel_pass(unused_pix02),        
        .load_weight(load_weight),
        .valid_in(valid_01),
        .valid_out(valid_02),
        .weight_in(weight_in_02),
        .pixel_in(pix_01_to_02),
        .PSum_In(EmptyPSumIN_2),
        .flush(flush),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_10
    (
        .PSum_Out(psum_10_to_20),
        .pixel_pass(pix_10_to_11),
        .load_weight(load_weight),
        .valid_in(valid_00),
        .valid_out(valid_10),
        .weight_in(weight_in_10),
        .pixel_in(pixel_in_R2),
        .PSum_In(psum_00_to_10),
        .flush(flush),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_11
    (
        .PSum_Out(psum_11_to_21),
        .pixel_pass(pix_11_to_12),        
        .load_weight(load_weight),
        .valid_in(valid_10_01),
        .valid_out(valid_11),
        .weight_in(weight_in_11),
        .pixel_in(pix_10_to_11),
        .PSum_In(psum_01_to_11),
        .flush(flush),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_12
    (
        .PSum_Out(psum_12_to_22),
        .pixel_pass(unused_pix12),        
        .load_weight(load_weight),
        .valid_in(valid_11_02),
        .valid_out(valid_12),
        .weight_in(weight_in_12),
        .pixel_in(pix_11_to_12),
        .PSum_In(psum_02_to_12),
        .flush(flush),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_20
    (
        .PSum_Out(PSum_Out_C1),
        .pixel_pass(pix_20_to_21),
        .load_weight(load_weight),
        .valid_in(valid_10),
        .valid_out(valid_20),
        .weight_in(weight_in_20),
        .pixel_in(pixel_in_R3),
        .PSum_In(psum_10_to_20),
        .flush(flush),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_21
    (
        .PSum_Out(PSum_Out_C2),
        .pixel_pass(pix_21_to_22),        
        .load_weight(load_weight),
        .valid_in(valid_11_20),
        .valid_out(valid_21),
        .weight_in(weight_in_21),
        .pixel_in(pix_20_to_21),
        .PSum_In(psum_11_to_21),
        .flush(flush),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_22
    (
        .PSum_Out(PSum_Out_C3),
        .pixel_pass(unused_pix22),        
        .load_weight(load_weight),
        .valid_in(valid_21_12),
        .valid_out(valid_out_3x3),
        .weight_in(weight_in_22),
        .pixel_in(pix_21_to_22),
        .PSum_In(psum_12_to_22),
        .flush(flush),
        .clk(clk),.RSTn(RSTn)  
    );
endmodule
