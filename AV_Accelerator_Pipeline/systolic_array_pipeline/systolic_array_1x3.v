`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2026 12:27:26
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
        input signed [Weight_Width-1:0] weight_in0,
        input signed [Weight_Width-1:0] weight_in1,
        input signed [Weight_Width-1:0] weight_in2,
        input [Pixel_Width-1:0] pixel_in_1x3,
        input signed [Acc_Width-1:0] PSum_In_1x3,
        input valid_in_1x3,
        input clk,RSTn
    );
    
    wire [Pixel_Width-1:0] pix_01;
    wire [Pixel_Width-1:0] pix_02;

    wire signed [Acc_Width-1:0] psum_01;
    wire signed [Acc_Width-1:0] psum_02;

    wire valid_01;
    wire valid_02;
    
    wire [Pixel_Width-1:0] unused_pix;
    wire signed [Weight_Width-1:0] weight_unused1,weight_unused2,weight_unused3;
    
    processing_element #(8,8,32) DUT_PE_1
    (
        .PSum_Out(psum_01),
        .pixel_pass(pix_01),.weight_pass(weight_unused1),
        .valid_in(valid_in_1x3),.valid_out(valid_01),
        .weight_in(weight_in0),.pixel_in(pixel_in_1x3),
        .PSum_In(PSum_In_1x3),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_2
    (
        .PSum_Out(psum_02),
        .pixel_pass(pix_02),.weight_pass(weight_unused2),
        .valid_in(valid_01),.valid_out(valid_02),
        .weight_in(weight_in1),.pixel_in(pix_01),
        .PSum_In(psum_01),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_3
    (
        .PSum_Out(PSum_Out_1x3),
        .pixel_pass(unused_pix),.weight_pass(weight_unused3),
        .valid_in(valid_02),.valid_out(valid_out_1x3),
        .weight_in(weight_in2),.pixel_in(pix_02),
        .PSum_In(psum_02),
        .clk(clk),.RSTn(RSTn)  
    );
    
endmodule


//TESTBENCH

module sys_array_1x3_tb;

    localparam Pixel_Width = 8, Weight_Width = 8, Acc_Width = 32;
    
        wire signed [Acc_Width-1:0] PSum_Out_1x3;
        wire valid_out_1x3;
        reg signed [Weight_Width-1:0] weight_in0;
        reg signed [Weight_Width-1:0] weight_in1;
        reg signed [Weight_Width-1:0] weight_in2;
        reg [Pixel_Width-1:0] pixel_in_1x3;
        reg signed [Acc_Width-1:0] PSum_In_1x3;
        reg valid_in_1x3;
        reg clk,RSTn;
        
        systolic_array_1x3 #(8,8,32) DUT_sys_arr_1X3
            (
                .PSum_Out_1x3(PSum_Out_1x3),
                .valid_out_1x3(valid_out_1x3),
                .weight_in0(weight_in0),.weight_in1(weight_in1),.weight_in2(weight_in2),
                .pixel_in_1x3(pixel_in_1x3),
                .PSum_In_1x3(PSum_In_1x3), 
                .valid_in_1x3(valid_in_1x3),
                .clk(clk),.RSTn(RSTn)      
            );
        
        task compute_sys_array;
            input [Pixel_Width-1:0] pixel_ip_1x3;
            input signed [Acc_Width-1:0] PSum_Ip_1x3;
            input valid_ip_1x3;
            
            begin
                pixel_in_1x3 = pixel_ip_1x3;
                PSum_In_1x3 = PSum_Ip_1x3;
                valid_in_1x3 = valid_ip_1x3;
                #10;
                $display("-------------------------------------------------");
                $display("Valid : %d",DUT_sys_arr_1X3.DUT_PE_1.valid_out);
                $display("Output of PE 1 : %d",DUT_sys_arr_1X3.DUT_PE_1.PSum_Out);
                $display("Pixel data %d was passed to next PE",DUT_sys_arr_1X3.DUT_PE_1.pixel_pass);
                
                $display("Valid : %d ",DUT_sys_arr_1X3.DUT_PE_2.valid_out);
                $display("Output of PE 2 : %d",DUT_sys_arr_1X3.DUT_PE_2.PSum_Out);
                $display("Pixel data %d was passed to next PE",DUT_sys_arr_1X3.DUT_PE_2.pixel_pass);
                
                $display("Valid : %d",DUT_sys_arr_1X3.DUT_PE_3.valid_out);
                $display("Output of PE 3 : %d",DUT_sys_arr_1X3.DUT_PE_3.PSum_Out);
                
                $display("Final Output = %d", PSum_Out_1x3);
                $display("Final Valid  = %b", valid_out_1x3);
                $display("-------------------------------------------------");
            end
        endtask
        
        always #5 clk = ~clk;
        
        initial 
        begin
        
            clk = 0; RSTn = 0; valid_in_1x3 = 0;
            PSum_In_1x3 = 0; pixel_in_1x3 = 0;
            weight_in0 = 0; weight_in1 = 0; weight_in2 = 0;
            
            #10 RSTn = 1;
            #10 weight_in0 = 8'd1; weight_in1 = 8'd2; weight_in2 = 8'd3;
            #10 compute_sys_array(8'd1,8'd0,8'd1);
            #10 compute_sys_array(8'd1,8'd0,8'd1);
            #10 compute_sys_array(8'd1,8'd0,8'd1);
            
            #10 weight_in0 = 8'd1; weight_in1 = 8'd2; weight_in2 = -8'd1;
            #10 compute_sys_array(8'd5,8'd0,8'd0);
            #10 compute_sys_array(8'd2,8'd0,8'd0);
            #10 compute_sys_array(8'd3,8'd0,8'd0);
            
            #10 weight_in0 = 8'd1; weight_in1 = 8'd2; weight_in2 = -8'd1;
            #10 compute_sys_array(8'd5,8'd0,8'd1);
            #10 compute_sys_array(8'd2,8'd0,8'd1);
            #10 compute_sys_array(8'd3,8'd0,8'd1);
            
            #10 weight_in0 = -8'd1; weight_in1 = 8'd3; weight_in2 = -8'd1;
            #10 compute_sys_array(8'd5,8'd2,8'd1);
            #10 compute_sys_array(8'd2,-8'd8,8'd1);
            #10 compute_sys_array(8'd3,-8'd3,8'd1);
            
            $finish;
        end 

endmodule 
