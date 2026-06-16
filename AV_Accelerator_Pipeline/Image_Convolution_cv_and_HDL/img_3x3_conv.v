`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.06.2026 15:50:14
// Design Name: 
// Module Name: img_3x3_conv
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


module img_3x3_conv(
                    output[31:0] conv,
                    input [71:0] patch,filter//8 bit * 9 weights = 72 

    );
    wire [7:0] p00 = patch[71:64];
    wire [7:0] f00 = filter[71:64];
    wire [7:0] p01 = patch[63:56];
    wire [7:0] f01 = filter[63:56];
    wire [7:0] p02 = patch[55:48];
    wire [7:0] f02 = filter[55:48];
    wire [7:0] p10 = patch[47:40];
    wire [7:0] f10 = filter[47:40];
    wire [7:0] p11 = patch[39:32];
    wire [7:0] f11 = filter[39:32];
    wire [7:0] p12 = patch[31:24];
    wire [7:0] f12 = filter[31:24];
    wire [7:0] p20 = patch[23:16];
    wire [7:0] f20 = filter[23:16];
    wire [7:0] p21 = patch[15:8];
    wire [7:0] f21 = filter[15:8];
    wire [7:0] p22 = patch[7:0];
    wire [7:0] f22 = filter[7:0];
    
    assign conv = (p00*f00) + (p01*f01) + (p02*f02)
                + (p10*f10) + (p11*f11) + (p12*f12)
                + (p20*f20) + (p21*f21) + (p22*f22);
endmodule

module img_conv_tb;
reg [71:0] p,f;
wire [31:0] conv;

img_3x3_conv mod_inst1(.patch(p),.filter(f),.conv(conv));

task calc_conv;
    input [71:0]ptch,fltr;
    begin
        p=ptch;f=fltr;
        #10;
        $display("convultion output : %d",conv);   
    end
endtask

initial 
    begin
        $display("Identity filter output:");
        calc_conv(72'hFF_FF_FF_FF_FF_FF_FF_FF_FF,72'h00_00_00_00_01_00_00_00_00);
        #10;
        $display("Blur filter output:");
        calc_conv(72'hFF_FF_FF_FF_FF_FF_FF_FF_FF,72'h01_01_01_01_01_01_01_01_01);
    end
endmodule 