`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:32:08
// Design Name: 
// Module Name: PE_tb
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


module PE_tb;

        localparam Pixel_Width=8, Weight_Width = 8,Acc_Width = 32;
        wire signed [Acc_Width-1:0] PSum_Out;
        wire [Pixel_Width-1:0] pixel_pass;
        wire valid_out;
        reg load_weight;
        reg signed [Weight_Width-1:0] weight_in;
        reg [Pixel_Width-1:0] pixel_in;
        reg signed [Acc_Width-1:0] PSum_In;
        reg valid_in;
        reg clk,RSTn;
    
    processing_element #(8,8,32) DUT_PE 
    (
        .PSum_Out(PSum_Out),
        .pixel_pass(pixel_pass),
        .load_weight(load_weight),
        .valid_in(valid_in),.valid_out(valid_out),
        .weight_in(weight_in),.pixel_in(pixel_in),
        .PSum_In(PSum_In),
        .clk(clk),.RSTn(RSTn)  
    );
    
    task compute_PE;
        input signed [Weight_Width-1:0] w_in; 
        input loadw;                         
        input [Pixel_Width-1:0] p_in;         
        input signed [Acc_Width-1:0] PSum_in; 
        input valid_input;                    
        
        begin
            @(negedge clk);
            weight_in   = w_in;
            load_weight = loadw;
            pixel_in    = p_in;
            PSum_In     = PSum_in;
            valid_in    = valid_input;
        end
    endtask
    
    always #5 clk = ~clk;
    
    always @(posedge clk) 
        begin
            if (RSTn) begin
                $strobe("Time: %0t ns  Load Weight: %b| Valid_In: %b | Weight_Reg: %d | Pixel_Pass: %d | PSum_Out: %d | Valid_Out: %b", 
                         $time, load_weight,valid_in, DUT_PE.weight_reg, pixel_pass, PSum_Out, valid_out);
            end
        end
        
    initial 
    begin
        clk=0; RSTn=0; weight_in =0; pixel_in=0; PSum_In=0; valid_in=0;
       
        //weight in (8), pixel in(8), PSum_In (32), valid_in (1)
        #15 RSTn = 1;
        //w_in(8) , loadW(1) , pixel_ip(8), PSum_ip(32) ,valid_in(1)
        //------------------------------------------------------
        // Test 1 : Load Weight
        //------------------------------------------------------
        compute_PE(8'd5, 1'b1, 8'd0, 32'd0, 1'b0);
        
        //------------------------------------------------------
        // Test 2 : Basic MAC
        //------------------------------------------------------
        compute_PE(8'd0, 1'b0, 8'd3, 32'd0, 1'b1);   // Expected = 15
        compute_PE(8'd0, 1'b0, 8'd6, 32'd0, 1'b1);   // Expected = 30
        
        //------------------------------------------------------
        // Test 3 : Accumulation
        //------------------------------------------------------
        compute_PE(8'd0, 1'b0, 8'd4, 32'd20, 1'b1);  // Expected = 40
        
        //------------------------------------------------------
        // Test 4 : Negative Weight
        //------------------------------------------------------
        compute_PE(-8'sd3, 1'b1, 8'd0, 32'd0, 1'b0); // Load -3
        compute_PE(8'd0, 1'b0, 8'd5, 32'd20, 1'b1);  // Expected = 5
        
        //------------------------------------------------------
        // Test 5 : Another Negative Weight
        //------------------------------------------------------
        compute_PE(-8'sd7, 1'b1, 8'd0, 32'd0, 1'b0); // Load -7
        compute_PE(8'd0, 1'b0, 8'd2, 32'd10, 1'b1);  // Expected = -4
        
        //------------------------------------------------------
        // Test 6 : Zero Weight
        //------------------------------------------------------
        compute_PE(8'd0, 1'b1, 8'd0, 32'd0, 1'b0);   // Load 0
        compute_PE(8'd0, 1'b0, 8'd255,32'd20,1'b1);  // Expected = 20
        
        //------------------------------------------------------
        // Test 7 : Zero Pixel
        //------------------------------------------------------
        compute_PE(8'd5, 1'b1, 8'd0, 32'd0, 1'b0);   // Load 5
        compute_PE(8'd0, 1'b0, 8'd0, 32'd35,1'b1);   // Expected = 35
        
        //------------------------------------------------------
        // Test 8 : Valid Bubble
        //------------------------------------------------------
        compute_PE(8'd0, 1'b0, 8'd7, 32'd0, 1'b1);
        compute_PE(8'd0, 1'b0, 8'd8, 32'd0, 1'b1);
        compute_PE(8'd0, 1'b0, 8'd0, 32'd0, 1'b0);
        compute_PE(8'd0, 1'b0, 8'd9, 32'd0, 1'b1);
        
        //------------------------------------------------------
        // Test 9 : Weight Reload
        //------------------------------------------------------
        compute_PE(8'd9, 1'b1, 8'd0, 32'd0, 1'b0);   // Load 9
        compute_PE(8'd0, 1'b0, 8'd2, 32'd0, 1'b1);   // Expected = 18
                    
                    
            #20 $finish; 
    end
    
endmodule
