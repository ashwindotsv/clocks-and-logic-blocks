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
    wire signed [Weight_Width-1:0] weight_unused;
    
    processing_element #(8,8,32) DUT_PE_1
    (
        .PSum_Out(psum_01),
        .pixel_pass(pix_01),
        .valid_in(valid_in_1x3),.valid_out(valid_01),
        .weight_in(weight_in0),.pixel_in(pixel_in_1x3),
        .PSum_In(PSum_In_1x3),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_2
    (
        .PSum_Out(psum_02),
        .pixel_pass(pix_02),
        .valid_in(valid_01),.valid_out(valid_02),
        .weight_in(weight_in1),.pixel_in(pix_01),
        .PSum_In(psum_01),
        .clk(clk),.RSTn(RSTn)  
    );
    
    processing_element #(8,8,32) DUT_PE_3
    (
        .PSum_Out(PSum_Out_1x3),
        .pixel_pass(weight_unused),
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
            input signed [Weight_Width-1:0] weight_ip0;
            input signed [Weight_Width-1:0] weight_ip1;
            input signed [Weight_Width-1:0] weight_ip2;
            input [Pixel_Width-1:0] pixel_ip_1x3;
            input signed [Acc_Width-1:0] PSum_Ip_1x3;
            input valid_ip_1x3;
            
            begin
                weight_in0 =  weight_ip0;
                weight_in1 =  weight_ip1;
                weight_in2 =  weight_ip2;
                pixel_in_1x3 = pixel_ip_1x3;
                PSum_In_1x3 = PSum_Ip_1x3;
                valid_in_1x3 = valid_ip_1x3;
                #10;
                $display("Valid : %d",DUT_sys_arr_1X3.DUT_PE_1.valid_out);
                $display("Output of PE 1 : %d",DUT_sys_arr_1X3.DUT_PE_1.PSum_Out);
                $display("Pixel data %d was passed to next PE",DUT_sys_arr_1X3.DUT_PE_1.pixel_in);
                
                $display("Valid : %d ",DUT_sys_arr_1X3.DUT_PE_2.valid_out);
                $display("Output of PE 2 : %d",DUT_sys_arr_1X3.DUT_PE_2.PSum_Out);
                $display("Pixel data %d was passed to next PE",DUT_sys_arr_1X3.DUT_PE_2.pixel_in);
                
                $display("Valid : %d",DUT_sys_arr_1X3.DUT_PE_3.valid_out);
                 $display("Output of PE 3 : %d",DUT_sys_arr_1X3.DUT_PE_3.PSum_Out);
            end
        endtask
        
        always #5 clk = ~clk;
        
        initial 
        begin
        
            clk = 0; RSTn = 0; valid_in_1x3 = 0;
            PSum_In_1x3 = 0; pixel_in_1x3 = 0;
            weight_in0 = 0; weight_in1 = 0; weight_in2 = 0;
            
            #10 RSTn = 1;
            repeat(10)
            compute_sys_array($random,$random,$random,$random,$random,$random);
            $finish;
        end 

endmodule 
