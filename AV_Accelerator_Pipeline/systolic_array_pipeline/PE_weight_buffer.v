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


module Processing_Element_FSM #(parameter Pixel_Width=8, Weight_Width = 8,Acc_Width = 32)
    (
    output reg signed [Acc_Width-1:0] PSum_Out,
    output reg [Pixel_Width-1:0] pixel_pass,
    output reg valid_out,
    input signed [Weight_Width-1:0] weight_in,
    input load_weight,
    input [Pixel_Width-1:0] pixel_in,
    input signed [Acc_Width-1:0] PSum_In,
    input valid_in,
    input clk,RSTn
    );
    
    reg [Weight_Width-1:0] weight_reg;
    reg CS,NS;
    localparam IDLE = 1'b0,COMPUTE = 1'b1;
    
    always @(posedge clk or negedge RSTn)
    begin
        if(~RSTn)
        begin
            PSum_Out <= 0;
            weight_reg <= 0;
            pixel_pass <= 0;
            valid_out <= 0;
            CS <= IDLE;
        end
        else 
        begin
            case (CS)
            IDLE :  begin
                        PSum_Out <= 0;
                        pixel_pass <= 0;
                        valid_out <= 0;
                        if ( load_weight )
                        weight_reg <= weight_in;
                    end
            COMPUTE : begin
                        if(valid_in)
                            begin
                               PSum_Out <= PSum_In + ( weight_reg * $signed({1'b0,pixel_in}) );
                               pixel_pass <= pixel_in;
                               valid_out <= 1'b1;  
                            end
                        else 
                            begin
                                valid_out <= 1'b0;
                            end    
                      end     
            endcase 
            CS <= NS;
        end
    end  
    
    always @(*)
    begin
        case(CS)
        IDLE  : begin
                    if( load_weight == 0) 
                        NS = IDLE;
                    else 
                        NS = COMPUTE;
                end
                
        COMPUTE  : begin 
                       if(valid_in) 
                            NS = COMPUTE;
                       else if ( load_weight )
                            NS = IDLE; 
                       else 
                            NS = CS;    
                   end    
                   
                   
        default : NS = CS;   
        endcase 
    end
endmodule

module PE_FSM_tb;
    
    localparam Pixel_Width=8, Weight_Width = 8,Acc_Width = 32;
    
        wire signed [Acc_Width-1:0] PSum_Out;
        wire [Pixel_Width-1:0] pixel_pass;
        wire valid_out;
        reg signed [Weight_Width-1:0] weight_in;
        reg [Pixel_Width-1:0] pixel_in;
        reg signed [Acc_Width-1:0] PSum_In;
        reg valid_in,load_weight;
        reg clk,RSTn;
    
        Processing_Element_FSM #(8,8,32) DUT_PE 
        (
            .PSum_Out(PSum_Out),
            .pixel_pass(pixel_pass),
            .valid_in(valid_in),
            .valid_out(valid_out),
            .weight_in(weight_in),
            .pixel_in(pixel_in),
            .PSum_In(PSum_In),
            .load_weight(load_weight),
            .clk(clk),.RSTn(RSTn)  
        );
        
        task compute_PE;
            input signed [Weight_Width-1:0] w_in;
            input loadw;
            input [Pixel_Width-1:0] pixel_ip;
            input signed [Acc_Width-1:0] PSum_Ip;
            input valid_ip;
            
            begin
                @(negedge clk)
                weight_in = w_in;
                load_weight = loadw;
                pixel_in = pixel_ip;
                PSum_In = PSum_Ip;
                valid_in = valid_ip;
            end
        endtask 
        
        always #5 clk = !clk;
        
        always @(posedge clk) 
        begin
            if (RSTn) begin
                $strobe("Time: %0t ns | State: %b | Valid_In: %b | Weight_Reg: %d | Pixel_Pass: %d | PSum_Out: %d | Valid_Out: %b", 
                         $time, DUT_PE.CS, valid_in, DUT_PE.weight_reg, pixel_pass, PSum_Out, valid_out);
            end
        end
        
        initial
        begin
            clk = 0; RSTn = 0; 
            weight_in = 0; load_weight =0;
            pixel_in = 0; PSum_In = 0;
            valid_in = 0;
            
            #15 RSTn = 1;
            //w_in(8) , loadW(1) , pixel_ip(8), PSum_ip(32) ,valid_in(1)
            compute_PE(8'd5, 1'b1, 8'd0, 32'b0, 1'b0);
            compute_PE(8'd0, 1'b0, 8'd3, 32'b0, 1'b1);
            compute_PE(8'd0, 1'b0, 8'd6, 32'b0, 1'b1);
            compute_PE(8'd0, 1'b0, 8'd0, 32'b0, 1'b0);
            #20 $finish;
        end
        
endmodule 