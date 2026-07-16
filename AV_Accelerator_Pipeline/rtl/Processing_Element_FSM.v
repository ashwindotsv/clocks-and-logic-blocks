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