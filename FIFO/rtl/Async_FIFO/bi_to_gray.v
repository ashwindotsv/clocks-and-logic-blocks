`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.04.2026 23:25:48
// Design Name: 
// Module Name: bi_to_gray
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

// no output reset bcoz gray = 0 ^ (0>>1) = 0. when count is rest automatically gray is reset too.
module bi_to_gray #(parameter N=4)(
    output reg [N-1:0] gray,
    input clk,RSTn
    );
    reg [N-1:0] count;
    always @ (posedge clk or negedge RSTn)
    begin
        if (~RSTn)
        begin
            count <= 0;
        end
        else
        begin
            if (count == (1<<N)-1)
                count <= 0;
            else
                count <= count + 1;
        end
    end
    
    always @ (*)
    begin
        gray = count ^ (count >> 1);
    end
endmodule


module b2g_tb;
parameter N=5;
reg clk, RSTn;
wire [N-1:0] gray;

bi_to_gray #(N)DUT (.clk(clk),.RSTn(RSTn),.gray(gray));

initial 
begin 
    $monitor("time=%0t gray=%b", $time, gray);
    clk =0;
    RSTn = 0;
    #10;
    RSTn = 1;
    #1500;
    $finish;
end 

always #5 clk = ~clk;


endmodule
