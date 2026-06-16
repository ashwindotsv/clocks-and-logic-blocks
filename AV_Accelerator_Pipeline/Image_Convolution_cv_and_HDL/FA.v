`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ashwin Nayak
// 
// Create Date: 01.06.2026 12:08:08
// Design Name: Full Adder
// Module Name: FA
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

// Change N to 8 for 8 bit adder 
module FA(
            output Sum, Carry,
            input A, B, Cin
    );
    assign Sum = A ^ B ^ Cin;
    assign Carry = A & B | B & Cin | Cin & A;
endmodule

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