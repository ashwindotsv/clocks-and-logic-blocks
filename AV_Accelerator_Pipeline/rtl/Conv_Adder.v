`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 20:20:34
// Design Name: 
// Module Name: Conv_Adder
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



module Conv_Adder#(parameter Acc_Width = 32)
    (
        output reg signed [Acc_Width-1:0] Conv_Out,
        output reg Conv_Out_Valid,
    
        input signed [Acc_Width-1:0] PSum_Out_C1,
        input signed [Acc_Width-1:0] PSum_Out_C2,
        input signed [Acc_Width-1:0] PSum_Out_C3,
    
        input valid_in,
        input clk,
        input RSTn
    );
    
    always @(posedge clk or negedge RSTn)
    begin 
        if (~RSTn)
        begin 
            Conv_Out <= 0;
            Conv_Out_Valid <= 0;
        end
        else if(valid_in)
        begin
           Conv_Out <= PSum_Out_C1 + PSum_Out_C2 + PSum_Out_C3;
           Conv_Out_Valid <= 1;
        end
        else   
        begin 
            Conv_Out_Valid<=0; 
        end
    end
endmodule
