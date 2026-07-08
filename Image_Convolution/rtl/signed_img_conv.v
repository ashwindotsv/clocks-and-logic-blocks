`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.06.2026 06:45:51
// Design Name: 
// Module Name: signed_img_conv
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


module signed_img_conv(
                        output signed[31:0] conv,
                        input signed [71:0] filter,
                        input [71:0] patch
    );
    
    wire [7:0] p00 = patch[71:64];
    wire signed [7:0] f00 = filter[71:64];
    wire  [7:0] p01 = patch[63:56];
    wire signed [7:0] f01 = filter[63:56];
    wire  [7:0] p02 = patch[55:48];
    wire signed [7:0] f02 = filter[55:48];
    wire  [7:0] p10 = patch[47:40];
    wire signed [7:0] f10 = filter[47:40];
    wire  [7:0] p11 = patch[39:32];
    wire signed [7:0] f11 = filter[39:32];
    wire  [7:0] p12 = patch[31:24];
    wire signed [7:0] f12 = filter[31:24];
    wire  [7:0] p20 = patch[23:16];
    wire signed [7:0] f20 = filter[23:16];
    wire  [7:0] p21 = patch[15:8];
    wire signed [7:0] f21 = filter[15:8];
    wire  [7:0] p22 = patch[7:0];
    wire signed [7:0] f22 = filter[7:0];
    
    wire signed [31:0] prod00 =$signed({1'b0, p00}) * f00;
    wire signed [31:0] prod01 = $signed({1'b0, p01}) * f01;
    wire signed [31:0] prod02 = $signed({1'b0, p02}) * f02;
    wire signed [31:0] prod10 = $signed({1'b0, p10}) * f10;
    wire signed [31:0] prod11 = $signed({1'b0, p11}) * f11;
    wire signed [31:0] prod12 = $signed({1'b0, p12}) * f12;
    wire signed [31:0] prod20 = $signed({1'b0, p20}) * f20;
    wire signed [31:0] prod21 = $signed({1'b0, p21}) * f21;
    wire signed [31:0] prod22 = $signed({1'b0, p22}) * f22;
    
    assign conv = prod00 + prod01 + prod02 + prod10 + prod11 + prod12 + prod20 + prod21 + prod22;
endmodule

module signed_img_conv_tb;
reg signed [71:0] fltr;
reg [71:0] ptch;
wire signed [31:0] conv;

signed_img_conv inst_mod1(.conv(conv),.patch(ptch),.filter(fltr));

task calc_conv;
    input signed [71:0]f;
    input [71:0] p;
    begin
        fltr=f;
        ptch=p;
        #10;
        $display("convultion output : %d",conv);   
    end
endtask

initial 
    begin // For 8-bit signed values: FF = -1, 00 = 0, 01 = 1
        $display("Identity Filter output");
        calc_conv(72'h00_00_00_00_01_00_00_00_00,72'h0A_14_1E_28_32_3C_46_50_5A);
        #10;
        $display("Sobel filter X output");
        calc_conv(72'hFF_00_01_FE_00_02_FF_00_01,72'h0A_14_1E_28_32_3C_46_50_5A);
        #10;
        $display(" Sobel filter Y output:");
        calc_conv(72'hFF_FE_FF_00_00_00_01_02_01,72'h0A_14_1E_28_32_3C_46_50_5A);
        #10;
        $display("laplacian kernel output");
        calc_conv(72'h00_01_00_01_FC_01_00_01_00 ,72'h0A_14_1E_28_32_3C_46_50_5A);
        #10;
        $display("sharp_kernel output");
        calc_conv(72'h00_FF_00_FF_05_FF_00_FF_00,72'h0A_14_1E_28_32_3C_46_50_5A);
        #10;
        $display("gaussian blur output");
        calc_conv(72'h01_02_01_02_04_02_01_02_01,72'h0A_14_1E_28_32_3C_46_50_5A);
        #10;
        $display("Blur filter output:");
        calc_conv(72'h01_01_01_01_01_01_01_01_01,72'h0A_14_1E_28_32_3C_46_50_5A);
        #10; 
        $finish;
    end
endmodule 