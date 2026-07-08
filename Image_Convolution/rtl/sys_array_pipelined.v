`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.06.2026 19:26:45
// Design Name: 
// Module Name: sys_array_pipelined
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


module conv3x3_pipelined #(parameter kernel_size = 3)
    (
        input clk, RSTn, valid,
        input [(kernel_size*kernel_size*8)-1:0] Feature_Data_In,
        input signed [(kernel_size*kernel_size*8)-1:0] Weight_In,
        output reg signed [31:0] Psum_Out,
        output reg Done
    );
    
        wire [7:0] Data00 = Feature_Data_In[71:64];
        wire signed [7:0] weight00 = Weight_In[71:64];
        wire [7:0] Data01 = Feature_Data_In[63:56];
        wire signed [7:0] weight01 = Weight_In[63:56];
        wire [7:0] Data02 = Feature_Data_In[55:48];
        wire signed [7:0] weight02 = Weight_In[55:48];
        wire [7:0] Data10 = Feature_Data_In[47:40];
        wire signed [7:0] weight10 = Weight_In[47:40];
        wire [7:0] Data11 = Feature_Data_In[39:32];
        wire signed [7:0] weight11 = Weight_In[39:32];
        wire [7:0] Data12 = Feature_Data_In[31:24];
        wire signed [7:0] weight12 = Weight_In[31:24];
        wire [7:0] Data20 = Feature_Data_In[23:16];
        wire signed [7:0] weight20 = Weight_In[23:16];
        wire [7:0] Data21 = Feature_Data_In[15:8];
        wire signed [7:0] weight21 = Weight_In[15:8];
        wire [7:0] Data22 = Feature_Data_In[7:0];
        wire signed [7:0] weight22 = Weight_In[7:0];  
        
          
    reg signed [15:0] reg_Mul1,reg_Mul2,reg_Mul3,reg_Mul4,reg_Mul5,reg_Mul6,reg_Mul7,reg_Mul8,reg_Mul9;
    reg valid_stage1;
    always @(posedge clk, negedge RSTn)
    begin
    if(~RSTn)
        begin
            Psum_Out <= 1'b0;Done <= 1'b0;
            reg_Mul1 <= 1'b0; reg_Mul2 <= 1'b0;reg_Mul3 <= 1'b0;reg_Mul4 <= 1'b0;
            reg_Mul5 <= 1'b0;reg_Mul6 <= 1'b0;reg_Mul7 <= 1'b0;reg_Mul8 <= 1'b0;reg_Mul9 <= 1'b0; 
            valid_stage1 <= 1'b0;
        end
    else
        begin
        valid_stage1 <= valid; 
        
        if (valid)
            begin
                reg_Mul1 <= $signed({1'b0,Data00})*weight00;
                reg_Mul2 <= $signed({1'b0,Data01})*weight01;
                reg_Mul3 <= $signed({1'b0,Data02})*weight02;
                reg_Mul4 <= $signed({1'b0,Data10})*weight10;
                reg_Mul5 <= $signed({1'b0,Data11})*weight11;
                reg_Mul6 <= $signed({1'b0,Data12})*weight12;
                reg_Mul7 <= $signed({1'b0,Data20})*weight20;
                reg_Mul8 <= $signed({1'b0,Data21})*weight21;
                reg_Mul9 <= $signed({1'b0,Data22})*weight22;
            end
        if (valid_stage1)
            begin
                Psum_Out <= reg_Mul1 + reg_Mul2 + reg_Mul3 + reg_Mul4 + reg_Mul5
                          + reg_Mul6 + reg_Mul7 + reg_Mul8 + reg_Mul9;
                                
                Done <= 1'b1;//set high; stage 2 complete
            end
        else 
            begin 
                Done <= 1'b0; //set low; process not complete yet
            end
        end 
    end
    
endmodule
