`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.06.2026 15:23:59
// Design Name: 
// Module Name: Mul_and_acc
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


module MAC(
            output [8:0] Y,
            input [3:0]A,B,C
    );
    wire [7:0]pro; 
    Mul_4bit inst_mod1(.product(pro),.A(A),.B(B));
    assign Y = pro + C;
    
endmodule

module MAC_tb;
reg [3:0] A,B,C;
wire [8:0] Y;

MAC inst_mod2(.Y(Y),.A(A),.B(B),.C(C));

task MAC_check;
    input [3:0] a,b,c;
    begin
        A=a;B=b;C=c;
       #10;
        if (Y !== (a * b) +c)
        $display("FAIL | A = %d | B = %d | C = %d | Expected = %d | Y = %d",A,B,C,A*B+C,Y);
        else
        $display("PASS | A = %d | B = %d | C = %d | Y = %d",A,B,C,Y);
    end
endtask

initial
begin 
    repeat (20)
    begin 
        MAC_check($random,$random,$random);
    end
end
endmodule