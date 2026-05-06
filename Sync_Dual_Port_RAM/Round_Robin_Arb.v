`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ashwin Nayak
// 
// Create Date: 05.05.2026 23:17:07
// Design Name: 
// Module Name: Round_Robin_Arb
// Project Name: 
// Target Devices: 
// Tool Versions: 
/*
// Description: 
Arbitration = deciding which request gets access when multiple requests conflict.
The round Robin Arbiter Rotates priority among requesters
*/
// 
//////////////////////////////////////////////////////////////////////////////////


module Round_Robin_Arb(
                        output reg grant_A, grant_B,
                        input request_A, request_B,clk,nRST
                        );
                        reg last_grant;//last_grant=0 ->A; last_grant =1 ->B
                        
                        always @(posedge clk or negedge nRST)
                        begin
                            if (!nRST)
                            begin
                                grant_A <= 1'b0;
                                grant_B <= 1'b0;
                                last_grant <= 1'b0;
                            end
                            else
                            begin
                                // default grants = 0
                                grant_A <= 1'b0;
                                grant_B <= 1'b0;
                                if (request_A && !request_B)
                                begin
                                    grant_A <= 1'b1;// A wins
                                    grant_B <= 1'b0;
                                    last_grant <= 1'b0;
                                end
                                else if (!request_A && request_B)
                                begin
                                    grant_B <= 1'b1;// B wins
                                    grant_A <= 1'b0;
                                    last_grant <= 1'b1;
                                end
                                else if (request_A && request_B)
                                begin
                                    // round robin using last_grant
                                    if (last_grant == 1'b0)
                                    begin 
                                        grant_B <= 1'b1;// B wins
                                        grant_A <= 1'b0;
                                        last_grant <= 1'b1;
                                    end
                                    else 
                                    begin
                                        grant_A <= 1'b1;// A wins
                                        grant_B <= 1'b0;
                                        last_grant <= 1'b0;
                                    end
                                end
                            end
                        end 
endmodule
