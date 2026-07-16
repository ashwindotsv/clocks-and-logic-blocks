`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:40:57
// Design Name: 
// Module Name: systolic_array_1x3_tb
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
