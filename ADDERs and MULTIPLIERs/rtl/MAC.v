`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 13:17:42
// Design Name: 
// Module Name: MAC
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


module MAC #(parameter Data_Width=8, Weight_Width = 8, Acc_Width = 32)
            (
            output signed [Acc_Width-1:0] MAC_Out,
            input signed [Weight_Width-1:0] Signed_In,
            input [Data_Width-1:0] Unsigned_In,
            input signed [Acc_Width-1:0] ACC
            );

    assign MAC_Out = ($signed({1'b0,Unsigned_In})*Signed_In) + ACC;
    
endmodule
