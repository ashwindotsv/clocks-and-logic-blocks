`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 23:52:18
// Design Name: 
// Module Name: systolic_array_tb
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
`timescale 1ns / 1ps


// INTERFACE
interface systolic_array_if #(
    parameter PIXEL_WIDTH = 8,WEIGHT_WIDTH = 8, ACC_WIDTH = 32)   
    (
    input logic clk
    );

    // Outputs from DUT
    logic signed [ACC_WIDTH-1:0] PSum_Out_C1, PSum_Out_C2, PSum_Out_C3;
    logic valid_out_3x3;
    
    // Inputs to DUT
    logic RSTn;
    logic load_weight;
    
    logic signed [WEIGHT_WIDTH-1:0] weight_in_00, weight_in_01, weight_in_02;
    logic signed [WEIGHT_WIDTH-1:0] weight_in_10, weight_in_11, weight_in_12;
    logic signed [WEIGHT_WIDTH-1:0] weight_in_20, weight_in_21, weight_in_22;
    
    logic [PIXEL_WIDTH-1:0] pixel_in_R1, pixel_in_R2, pixel_in_R3;
    logic signed [ACC_WIDTH-1:0] PSum_In_3x3;
    logic valid_in_3x3;
    
    // Clocking block
    clocking cb @(posedge clk);
        default input #1 output #1;
        
        // TB samples these (from DUT)
        input PSum_Out_C1, PSum_Out_C2, PSum_Out_C3;
        input valid_out_3x3;
        
        // TB drives these (to DUT)
        output weight_in_00, weight_in_01, weight_in_02;
        output weight_in_10, weight_in_11, weight_in_12;
        output weight_in_20, weight_in_21, weight_in_22;
        output pixel_in_R1, pixel_in_R2, pixel_in_R3;
        output PSum_In_3x3;
        output valid_in_3x3;
        output load_weight;
    endclocking
    
    // Modports
    modport TB (
        clocking cb,
        output RSTn
    );
    
    modport DUT (
        input clk,
        input RSTn,
        input weight_in_00, weight_in_01, weight_in_02,
        input weight_in_10, weight_in_11, weight_in_12,
        input weight_in_20, weight_in_21, weight_in_22,
        input pixel_in_R1, pixel_in_R2, pixel_in_R3,
        input PSum_In_3x3,
        input valid_in_3x3,
        input load_weight,
        output PSum_Out_C1, PSum_Out_C2, PSum_Out_C3,
        output valid_out_3x3
    );

endinterface


// PACKAGE

package systolic_array_pkg;
    typedef logic signed [31:0] acc_t;
    typedef logic signed [7:0] weight_t;
    typedef logic [7:0] pixel_t;
endpackage


// TESTBENCH

module systolic_array_tb;
    import systolic_array_pkg::*;
    
    // Parameters
    parameter Pixel_Width = 8;
    parameter Weight_Width = 8;
    parameter Acc_Width = 32;
    
    // Clock
    logic clk = 0;
    always #5 clk = ~clk;
    
    // Interface
    systolic_array_if #(
        .PIXEL_WIDTH(Pixel_Width),
        .WEIGHT_WIDTH(Weight_Width),
        .ACC_WIDTH(Acc_Width)
    ) vif(.clk(clk));
    
    // DUT
    Systolic_Array_3x3 #(
        .Pixel_Width(Pixel_Width),
        .Weight_Width(Weight_Width),
        .Acc_Width(Acc_Width)
    ) DUT (
        .PSum_Out_C1(vif.PSum_Out_C1),
        .PSum_Out_C2(vif.PSum_Out_C2),
        .PSum_Out_C3(vif.PSum_Out_C3),
        .valid_out_3x3(vif.valid_out_3x3),
        .weight_in_00(vif.weight_in_00),
        .weight_in_01(vif.weight_in_01),
        .weight_in_02(vif.weight_in_02),
        .weight_in_10(vif.weight_in_10),
        .weight_in_11(vif.weight_in_11),
        .weight_in_12(vif.weight_in_12),
        .weight_in_20(vif.weight_in_20),
        .weight_in_21(vif.weight_in_21),
        .weight_in_22(vif.weight_in_22),
        .pixel_in_R1(vif.pixel_in_R1),
        .pixel_in_R2(vif.pixel_in_R2),
        .pixel_in_R3(vif.pixel_in_R3),
        .PSum_In_3x3(vif.PSum_In_3x3),
        .valid_in_3x3(vif.valid_in_3x3),
        .load_weight(vif.load_weight),
        .clk(vif.clk),
        .RSTn(vif.RSTn)
    );
    
    
endmodule
