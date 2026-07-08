`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 13:28:07
// Design Name: 
// Module Name: RCA_Nbit
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

module RCA_Nbit #(parameter N=4)(
            output[N-1:0]Sum,
            output Cout,
            input [N-1:0]A,B,
            input Cin
    );
    wire [N:0] carry_int;
    genvar j;
    assign carry_int[0] = Cin;
    generate 
    for (j = 0; j < N ; j = j + 1)
        begin
            FA fa_block (.Sum(Sum[j]),.A(A[j]),.B(B[j]),.Cin(carry_int[j]),.Carry(carry_int[j+1]));
        end
    endgenerate 
    assign Cout = carry_int[N];
endmodule 

