`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2026 00:01:54
// Design Name: 
// Module Name: ReLU
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


module ReLU#(parameter Acc_Width = 32)
    (
        output reg signed [Acc_Width-1:0] ReLU_Out,
        input signed [Acc_Width-1:0] ReLU_In
    );
    
    always @ (*)
    begin
        ReLU_Out = 0;
        if( ReLU_In < 0)
                begin
                    ReLU_Out = 0;
                end
        else
                begin 
                    ReLU_Out = ReLU_In;
                end
    end
endmodule
