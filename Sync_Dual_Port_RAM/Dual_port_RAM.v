`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:Ashwin Nayak
// 
// Create Date: 20.04.2026 10:14:56
// Design Name: Synchronous Dual port RAM
// Module Name: Dual_port_RAM
// Project Name: Memory Interface Verification System
/* 
// Description: 
The design of a synchronous(both port updates on same clock edge), parametrised Dual port RAM with active low reset.
In case of collision i.e A_en = 1 && B_en = 1 && We_A = 1  && We_B && Address_A == Address_B, 
the RAM is hardcoded to write the data from PORT A. 
Further additons : Arbiter circuit for port detection while collision, Double Data Rate, Error correction codes. 
*/ 
//////////////////////////////////////////////////////////////////////////////////


// PORT_A gets priority when write is asserted   

module Sync_Dual_port_RAM #(parameter Width=8, Depth=32)(
    input clk, RSTn,
    //port A
    output reg [Width-1:0]Data_Out_A,
    input [Width-1:0]Data_In_A,
    input A_en,We_A, Re_A, 
    input [$clog2(Depth)-1:0] Address_A,
    //port B
    output reg [Width-1:0]Data_Out_B,
    input [Width-1:0]Data_In_B,
    input B_en,We_B, Re_B, 
    input [$clog2(Depth)-1:0] Address_B   
    );
    
    reg [Width-1:0] mem [0:Depth-1];
    
    always @ (posedge clk)
    begin
        //reset behaviour
        if (~RSTn)
        begin
            Data_Out_A <= 0;
            Data_Out_B <= 0;
        end 
        else 
        begin
            //anti latch 
            Data_Out_A <= Data_Out_A;
            Data_Out_B <= Data_Out_B;
                //PORT A
                if (A_en)
                begin
                    if (We_A)
                    begin 
                        mem[Address_A] <= Data_In_A;
                        Data_Out_A <= Data_In_A;
                    end
                    else if (Re_A)
                    begin
                        Data_Out_A <= mem[Address_A];
                    end  
                end     
                //PORT B 
                if (B_en)
                begin
                    //conflict between Port A and B 
                    if (A_en && We_A && Address_A == Address_B) 
                    begin
                        if (Re_B)
                        begin 
                            Data_Out_B <= Data_Out_B;
                             // Port A gets the priority in conflict  
                             //Port B holds the previous value   
                        end
                    end
                    else if (We_B)
                    begin
                        mem[Address_B] <= Data_In_B;
                        Data_Out_B <= Data_In_B;
                    end
                    else if (Re_B)
                    begin                       
                        Data_Out_B <= mem[Address_B];
                    end
                end 
        end
     end
endmodule