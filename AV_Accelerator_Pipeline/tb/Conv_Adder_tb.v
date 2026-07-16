`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 20:58:10
// Design Name: 
// Module Name: Conv_Adder_tb
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


module Conv_Adder_tb;

    localparam Acc_Width = 32;

    reg clk, RSTn;
    reg valid_in;

    reg signed [Acc_Width-1:0] PSum_Out_C1;
    reg signed [Acc_Width-1:0] PSum_Out_C2;
    reg signed [Acc_Width-1:0] PSum_Out_C3;

    wire signed [Acc_Width-1:0] Conv_Out;
    wire Conv_Out_Valid;

    Conv_Adder #(Acc_Width) DUT
    (
        .Conv_Out(Conv_Out),
        .Conv_Out_Valid(Conv_Out_Valid),
        .PSum_Out_C1(PSum_Out_C1),
        .PSum_Out_C2(PSum_Out_C2),
        .PSum_Out_C3(PSum_Out_C3),
        .valid_in(valid_in),
        .clk(clk),
        .RSTn(RSTn)
    );

    always #5 clk = ~clk;

    task compute_conv;
        input signed [31:0] c1,c2,c3;
        input valid;
        begin
            @(negedge clk);
            PSum_Out_C1 = c1;
            PSum_Out_C2 = c2;
            PSum_Out_C3 = c3;
            valid_in    = valid;
        end
    endtask

    always @(posedge clk)
    begin
        if(RSTn)
        begin
            $strobe("Time=%0t | C1=%0d C2=%0d C3=%0d | Conv=%0d | Valid=%b",
                    $time,
                    PSum_Out_C1,
                    PSum_Out_C2,
                    PSum_Out_C3,
                    Conv_Out,
                    Conv_Out_Valid);
        end
    end

    initial
    begin
        clk = 0;
        RSTn = 0;
        valid_in = 0;
        PSum_Out_C1 = 0;
        PSum_Out_C2 = 0;
        PSum_Out_C3 = 0;

        #15 RSTn = 1;

        compute_conv(10,20,30,1);
        compute_conv(40,-10,20,1);
        compute_conv(-5,-15,-20,1);
        compute_conv(30,-10,-20,1);
        compute_conv(0,0,0,0);

        #20 $finish;
    end

endmodule
