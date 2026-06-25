`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.06.2026 14:19:32
// Design Name: 
// Module Name: processing_element
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


module processing_element #(parameter Pixel_Width=8, Weight_Width = 8,Acc_Width = 32)
    (
    output reg signed [Acc_Width-1:0] PSum_Out,
    output reg [Pixel_Width-1:0] pixel_pass,
    output reg signed [Weight_Width-1:0] weight_pass,
    output reg valid_out,
    input signed [Weight_Width-1:0] weight_in,
    input [Pixel_Width-1:0] pixel_in,
    input signed [Acc_Width-1:0] PSum_In,
    input valid_in,
    input clk,RSTn
    );
    
    always @(posedge clk or negedge  RSTn)
    begin
        if(~RSTn)
        begin
            PSum_Out <= 0;
            pixel_pass <= 0;
            weight_pass <= 0;
            valid_out <= 0;
        end 
        else 
        begin
            if(valid_in)
            begin
                PSum_Out <= PSum_In + ( weight_in * $signed({1'b0,pixel_in}) );
                pixel_pass <= pixel_in;
                weight_pass <= weight_in;
                valid_out <= 1'b1;
            end
            else
            begin   
                valid_out <= 1'b0;
                pixel_pass <= pixel_in;
                weight_pass <= weight_in;
            end
        end
    end
endmodule


module PE_tb;

        localparam Pixel_Width=8, Weight_Width = 8,Acc_Width = 32;
        wire signed [Acc_Width-1:0] PSum_Out;
        wire [Pixel_Width-1:0] pixel_pass;
        wire signed [Weight_Width-1:0] weight_pass;
        wire valid_out;
        reg signed [Weight_Width-1:0] weight_in;
        reg [Pixel_Width-1:0] pixel_in;
        reg signed [Acc_Width-1:0] PSum_In;
        reg valid_in;
        reg clk,RSTn;
    
    processing_element #(8,8,32) DUT_PE 
    (
        .PSum_Out(PSum_Out),
        .pixel_pass(pixel_pass),.weight_pass(weight_pass),
        .valid_in(valid_in),.valid_out(valid_out),
        .weight_in(weight_in),.pixel_in(pixel_in),
        .PSum_In(PSum_In),
        .clk(clk),.RSTn(RSTn)  
    );
    
    task pe_model;
        
        input valid_input;
        input signed [Weight_Width-1:0] w_in;
        input [Pixel_Width-1:0] p_in;
        input signed [Acc_Width-1:0] PSum_in;
    
        begin
            weight_in = w_in;
            pixel_in = p_in;
            PSum_In = PSum_in;
            valid_in = valid_input;
            #10;
            $display("Valid_in : %d \nOUTPUT: %d",valid_in,PSum_Out);
            $display("The %d pixel is passed to next PE",pixel_pass);
            $display("The %d weight is passed to next PE",weight_pass);
        end
    endtask
    
    always #5 clk = ~clk;
    
    initial 
    begin
        clk=0; RSTn=0; weight_in =0; pixel_in=0; PSum_In=0; valid_in=0;
        #10;
        RSTn = 1;
        #10 pe_model(1,100,200,300); 
        #10 pe_model(0,10,20,30); 
        #10 pe_model(1,50,60,70);
        #10 pe_model(1,-5,20,100);
        #10 pe_model(1,-5,20,-100);
        $finish; 
    end
    
endmodule 