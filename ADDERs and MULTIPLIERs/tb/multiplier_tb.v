`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 13:20:39
// Design Name: 
// Module Name: multiplier_tb
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
module multiplier_tb;
reg [3:0] A,B;
wire [7:0] pro;

Mul_4bit inst1 (.product(pro),.A(A),.B(B));

task pro_check;
    input [3:0]a,b;
    begin 
        A=a;B=b;
        #10;
        if (pro !== a*b)
        $display("FAIL | A = %b | B = %b | Expected = %b | Product = %b",A,B,A*B,pro);
        else
        $display("PASS | A = %b | B = %b | Product = %b",A,B,pro);
    end 
endtask
initial 
    begin
        repeat(20)
        begin 
            pro_check($random,$random);
        end
        $finish;
    end
endmodule