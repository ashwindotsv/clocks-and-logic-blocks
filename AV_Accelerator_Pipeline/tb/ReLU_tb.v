`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 21:00:05
// Design Name: 
// Module Name: ReLU_tb
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


module ReLU_tb;

    localparam Acc_Width = 32;

    reg signed [Acc_Width-1:0] ReLU_In;
    wire signed [Acc_Width-1:0] ReLU_Out;

    ReLU #(Acc_Width) DUT
    (
        .ReLU_Out(ReLU_Out),
        .ReLU_In(ReLU_In)
    );

    initial
    begin

        $monitor("Time=%0t | Input=%0d | Output=%0d",
                  $time,
                  ReLU_In,
                  ReLU_Out);

        ReLU_In = 50;
        #10;

        ReLU_In = 0;
        #10;

        ReLU_In = -1;
        #10;

        ReLU_In = -45;
        #10;

        ReLU_In = 127;
        #10;

        ReLU_In = -32768;
        #10;

        $finish;

    end

endmodule