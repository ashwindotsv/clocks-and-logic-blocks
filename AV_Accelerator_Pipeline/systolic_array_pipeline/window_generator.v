`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.06.2026 12:31:11
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


module window_gen_tb;

        localparam kernel_size=3;
    
        wire [((kernel_size)*(kernel_size)*8)-1:0] Feature_Data;
        wire window_out_valid;
        reg clk, RSTn,window_in_valid;
        reg [7:0] pix_row1, pix_row2,pix_row3;
        
        window_generator #(3) DUT_win_gen(
        .RSTn(RSTn),.clk(clk),
        .Feature_Data(Feature_Data),
        .window_out_valid(window_out_valid),.window_in_valid(window_in_valid),
        .pix_row1(pix_row1),.pix_row2(pix_row2),.pix_row3(pix_row3)
        );
        
        task gen_win;
            input [7:0] pr1,pr2,pr3;
            input win_in_vld;
            begin
                pix_row1 = pr1; 
                pix_row2 = pr2; 
                pix_row3 = pr3;
                window_in_valid = win_in_vld;
                #10;
                @(posedge clk);  // wait for clock edge
                #1;              // tiny delay to let registers settle
                $display(
                "valid=%b \n D00=%0d D01=%0d D02=%0d \n D10=%0d D11=%0d D12=%0d \n D20=%0d D21=%0d D22=%0d \n",
                window_out_valid,
                DUT_win_gen.Dreg00, DUT_win_gen.Dreg01, DUT_win_gen.Dreg02,
                DUT_win_gen.Dreg10, DUT_win_gen.Dreg11, DUT_win_gen.Dreg12,
                DUT_win_gen.Dreg20, DUT_win_gen.Dreg21, DUT_win_gen.Dreg22
                );
                    end
        endtask
        
        always #5 clk = ~clk;
        
        initial 
        begin
            clk = 0; RSTn = 0; window_in_valid =0;
            pix_row1 = 0; pix_row2 = 0; pix_row3 = 0;
            #10;
            RSTn = 1; window_in_valid =1;
            #10 gen_win(8'd10,8'd20,8'd30,1);
            #10 gen_win(8'd40,8'd50,8'd60,1);
            #10 gen_win(8'd70,8'd80,8'd90,1);
            #10 gen_win(8'd100,8'd110,8'd120,0);
            #10 gen_win(8'd130,8'd140,8'd150,0);
            #10 gen_win(8'd160,8'd170,8'd180,1);
            #10 gen_win(8'd190,8'd200,8'd210,1);
            RSTn = 0; window_in_valid =1;
            #10 gen_win(8'd10,8'd20,8'd30,1);
            #10 gen_win(8'd40,8'd50,8'd60,1);
            #10 gen_win(8'd70,8'd80,8'd90,1);
            #10 gen_win(8'd100,8'd110,8'd120,0);
            #10 gen_win(8'd130,8'd140,8'd150,0);
            #10 gen_win(8'd160,8'd170,8'd180,1);
            #10 gen_win(8'd190,8'd200,8'd210,1);
            RSTn = 1; window_in_valid =0;
            #10 gen_win(8'd10,8'd20,8'd30,1);
            #10 gen_win(8'd40,8'd50,8'd60,1);
            #10 gen_win(8'd70,8'd80,8'd90,1);
            #10 gen_win(8'd100,8'd110,8'd120,0);
            #10 gen_win(8'd130,8'd140,8'd150,0);
            #10 gen_win(8'd160,8'd170,8'd180,1);
            #10 gen_win(8'd190,8'd200,8'd210,1);
            RSTn = 1; window_in_valid =1;
            #10 gen_win(8'd10,8'd20,8'd30,1);
            #10 gen_win(8'd40,8'd50,8'd60,1);
            #10 gen_win(8'd70,8'd80,8'd90,1);
            #10 gen_win(8'd100,8'd110,8'd120,0);
            #10 gen_win(8'd130,8'd140,8'd150,0);
            #10 gen_win(8'd160,8'd170,8'd180,1);
            #10 gen_win(8'd190,8'd200,8'd210,1);
            #10 gen_win(8'd10,8'd20,8'd30,1);
            #10 gen_win(8'd40,8'd50,8'd60,1);
            #10 gen_win(8'd70,8'd80,8'd90,1);
            #10 gen_win(8'd100,8'd110,8'd120,0);
            #10 gen_win(8'd130,8'd140,8'd150,0);
            #10 gen_win(8'd160,8'd170,8'd180,1);
            #10 gen_win(8'd190,8'd200,8'd210,1);
            $finish;
        end
endmodule 