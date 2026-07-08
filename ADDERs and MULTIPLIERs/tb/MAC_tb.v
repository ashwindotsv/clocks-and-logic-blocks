`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 13:15:42
// Design Name: 
// Module Name: MAC_tb
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


module MAC_tb;

    localparam Data_Width=8;
    localparam Weight_Width = 8;
    localparam Acc_Width = 32;
    
    reg signed [Weight_Width-1:0] Signed_In;
    reg [Data_Width-1:0]Unsigned_In;
    reg signed [Acc_Width-1:0] ACC;
    wire signed [Acc_Width-1:0] MAC_Out;
    
    MAC #(8,8,32) inst_mod2(.MAC_Out(MAC_Out),.Signed_In(Signed_In),.Unsigned_In(Unsigned_In),.ACC(ACC));
    
    task MAC_check;
        input signed [Weight_Width-1:0] a;
        input [Data_Width-1:0] b;
        input signed [Acc_Width-1:0] c;
        
        begin
            Signed_In=a;Unsigned_In=b;ACC=c;
           #10;
            if (MAC_Out !== (a * $signed({1'b0, b})) +c)
            $display("FAIL | A = %d | B = %d | C = %d | Expected = %d | Y = %d",Signed_In,Unsigned_In,ACC,Signed_In*Unsigned_In+ACC,MAC_Out);
            else
            $display("PASS | A = %d | B = %d | C = %d | MAC_Out = %d",Signed_In,Unsigned_In,ACC,MAC_Out);
        end
    endtask
    
    initial
    begin 
        repeat (20)
        begin 
            MAC_check($random,$random,$random);
        end
        $finish;
    end
endmodule
