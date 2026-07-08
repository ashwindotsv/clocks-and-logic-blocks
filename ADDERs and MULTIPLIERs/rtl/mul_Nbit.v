`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 14:27:26
// Design Name: 
// Module Name: mul_Nbit
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


module mul_Nbit #(parameter N=8)(
                output [2*N-1:0] Y,
                input [N-1:0] A,B
    );
    assign Y = A * B;
    
endmodule
