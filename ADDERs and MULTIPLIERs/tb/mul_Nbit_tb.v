`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 13:24:23
// Design Name: 
// Module Name: mul_Nbit_tb
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


module mul_Nbit_tb;
localparam N =8;
reg [N-1:0] A,B;
wire [2*N-1:0] Y;

mul_Nbit #(8) mod_inst(.Y(Y),.A(A),.B(B));
initial begin
    repeat(20) begin
        A = $random;
        B = $random;
        #10;
        if(Y !== A*B)
            $display("FAIL: A=%0d B=%0d Expected=%0d Got=%0d", A, B, A*B, Y);
        else
            $display("PASS: A=%0d B=%0d Y=%0d", A, B, Y);
    end
    $finish;
end
endmodule 
