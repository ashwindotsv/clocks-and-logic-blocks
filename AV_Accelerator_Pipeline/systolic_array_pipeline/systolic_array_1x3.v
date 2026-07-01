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
        reg valid_in_1x3,load_weight;
        reg clk,RSTn;
        
        systolic_array_1x3 #(8,8,32) DUT_sys_arr_1X3
            (
                .PSum_Out_1x3(PSum_Out_1x3),
                .valid_out_1x3(valid_out_1x3),
                .weight_in0(weight_in0),.weight_in1(weight_in1),.weight_in2(weight_in2),
                .pixel_in_1x3(pixel_in_1x3),
                .PSum_In_1x3(PSum_In_1x3),
                .load_weight(load_weight), 
                .valid_in_1x3(valid_in_1x3),
                .clk(clk),.RSTn(RSTn)      
            );
        
        task compute_sys_array_1x3;
            input [Pixel_Width-1:0] pixel_ip_1x3;
            input valid_ip_1x3,load_w;
            
            begin
                @(negedge clk)
                pixel_in_1x3 = pixel_ip_1x3;
                valid_in_1x3 = valid_ip_1x3;
                load_weight = load_w;
            end
        endtask
        
        always #5 clk = ~clk;
        
        always @(posedge clk)
        begin
            $strobe("-------------------------------------------------------------------------");
            $strobe("\n Time: %0t ns  Load Weight: %b| Valid_In 1: %b | Valid_In 2: %b |  Valid_In 3: %b\n",
            $time, load_weight,DUT_sys_arr_1X3.DUT_PE_1.valid_in,DUT_sys_arr_1X3.DUT_PE_2.valid_in,DUT_sys_arr_1X3.DUT_PE_3.valid_in);
            $strobe(" Weight_Reg 1: %d | Weight_Reg 2: %d |Weight_Reg 3: %d \n",
            DUT_sys_arr_1X3.DUT_PE_1.weight_reg,DUT_sys_arr_1X3.DUT_PE_2.weight_reg,DUT_sys_arr_1X3.DUT_PE_3.weight_reg);
            $strobe("Pixel_Pass 1: %d | Pixel_Pass 2: %d | ",
            DUT_sys_arr_1X3.DUT_PE_1.pixel_pass,DUT_sys_arr_1X3.DUT_PE_2.pixel_pass); 
            $strobe(" PSum_Out 1: %d |  PSum_Out 2: %d |  PSum_Out 3: %d Valid_Out: %b",
            DUT_sys_arr_1X3.DUT_PE_1.PSum_Out,DUT_sys_arr_1X3.DUT_PE_2.PSum_Out,DUT_sys_arr_1X3.DUT_PE_3.PSum_Out,valid_out_1x3);               
        end
        
        initial 
        begin
        
            clk = 0; RSTn = 0; 
            valid_in_1x3 = 0; load_weight =0;
            PSum_In_1x3 = 0; pixel_in_1x3 = 0;
            weight_in0 = 0; weight_in1 = 0; weight_in2 = 0;
            
            #15 RSTn = 1; 
            weight_in0 = 8'd10; weight_in1 = 8'd20; weight_in2 = 8'd30;//2. Load Weights Into PEs
            
            compute_sys_array_1x3(8'd0, 1'b0, 1'b1); // Cycle 1: load_weight = 1
            compute_sys_array_1x3(8'd0, 1'b0, 1'b0); // Cycle 2: Turn off load_weight
            
            compute_sys_array_1x3(8'd1, 1'b1, 1'b0); // Cycle 1: X0 = 1
            compute_sys_array_1x3(8'd2, 1'b1, 1'b0); // Cycle 2: X1 = 2
            compute_sys_array_1x3(8'd3, 1'b1, 1'b0); // Cycle 3: X2 = 3
            compute_sys_array_1x3(8'd4, 1'b1, 1'b0); // Cycle 4: X3 = 4
            
            // 4. Flush the Pipeline (Clear valid_in while data clears out)
            compute_sys_array_1x3(8'd0, 1'b0, 1'b0); // Cycle 5
            compute_sys_array_1x3(8'd0, 1'b0, 1'b0); // Cycle 6
            compute_sys_array_1x3(8'd0, 1'b0, 1'b0); // Cycle 7
            #20;
            $finish;
        end 

endmodule 
