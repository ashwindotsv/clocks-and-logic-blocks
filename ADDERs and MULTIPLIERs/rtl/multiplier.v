`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 13:22:06
// Design Name: 
// Module Name: multiplier
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


module Mul_4bit(
                output [7:0]product,
                input [3:0] A,B
    );
    wire [7:0] pp0,pp1,pp2,pp3;
    
    assign pp0 = {4'b0000 , ( B & {4{A[0]}})};
    assign pp1 = {3'b000, (B & {4{A[1]}}), 1'b0};
    assign pp2 = {2'b00, (B & {4{A[2]}}), 2'b00};
    assign pp3 = {1'b0, (B & {4{A[3]}}), 3'b000};
    
    assign product = pp0 + pp1 + pp2 + pp3;
endmodule
