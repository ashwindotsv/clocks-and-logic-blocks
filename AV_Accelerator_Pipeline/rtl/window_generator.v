`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 12:33:57
// Design Name: 
// Module Name: window_generator
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


module window_generator #(parameter kernel_size = 3)
    (
        output reg [((kernel_size)*(kernel_size)*8)-1:0] Feature_Data,
        output reg window_out_valid,
        input clk, RSTn,window_in_valid,
        input [7:0] pix_row1, pix_row2,pix_row3                                                                                    
    );
    
    reg [7:0] Dreg00, Dreg01, Dreg02, Dreg10, Dreg11, Dreg12, Dreg20, Dreg21, Dreg22;
    reg [1:0] col_count;
    
    always @(posedge clk , negedge RSTn)
    begin
    if(~RSTn)
        begin
            Feature_Data <= 0;
            window_out_valid <=0;
            Dreg00 <= 0; Dreg01 <= 0; Dreg02 <= 0;
            Dreg10 <= 0; Dreg11 <= 0; Dreg12 <= 0;
            Dreg20 <= 0; Dreg21 <= 0; Dreg22 <= 0;
            col_count <=0;
        end
    else
        begin
            if (window_in_valid)
            begin
                   Dreg00 <= Dreg01;
                   Dreg01 <= Dreg02;
                   Dreg02 <= pix_row1;
                   
                   Dreg10 <= Dreg11;
                   Dreg11 <= Dreg12;
                   Dreg12 <= pix_row2;
                   
                   Dreg20 <= Dreg21;
                   Dreg21 <= Dreg22;
                   Dreg22 <= pix_row3;
                   
                   Feature_Data <= {Dreg00, Dreg01, Dreg02, 
                                    Dreg10, Dreg11, Dreg12, 
                                    Dreg20, Dreg21, Dreg22};
                   if (col_count >= 2)
                       begin                 
                       window_out_valid <= 1;
                        end
                    else col_count <= col_count + 1;
            end 
            else 
                begin 
                    window_out_valid <= 0;
                end
        end
    end
endmodule

