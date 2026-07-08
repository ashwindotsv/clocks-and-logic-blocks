`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 13:19:26
// Design Name: 
// Module Name: RCA_tb
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

// self checking testbench for Adder 
module RCA_tb;
localparam N = 8;
reg [N-1:0] A,B;
reg Cin;
wire [N-1:0] Sum;
wire Cout;

RCA_Nbit #(8) RCA_module(.Sum(Sum),.A(A),.B(B),.Cin(Cin),.Cout(Cout));

task RCA_check;
input [N-1:0] a,b;
input c;
    begin
        A = a; B = b ; Cin = c; 
        #10;
        if({Cout,Sum} !== a + b + c)
        begin
            $display("FAIL: A = %b | B = %b | Cin = %b | Expected = %d | Cout = %b | Sum = %b ",A,B,Cin,a+b+c,Cout,Sum);
        end 
        else
        begin
            $display("PASS: A = %b | B = %b | Cin = %b | Cout = %b | Sum = %b ",A,B,Cin,Cout,Sum);
        end
    end
endtask 

initial
    begin
    repeat(20)
        begin
            RCA_check($random,$random,$random);    
        end
        $finish;
    end
endmodule 
