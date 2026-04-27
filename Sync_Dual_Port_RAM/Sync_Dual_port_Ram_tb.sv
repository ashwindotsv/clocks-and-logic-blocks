`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2026 14:24:17
// Design Name: 
// Module Name: Sync_Dual_port_Ram_tb
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
package dual_port_ram;

localparam  Width=8;
localparam Depth=32;

    class generator;
        rand logic [7:0] Data_In;
        function void gen_txn();
        
        endfunction  
    endclass
    class driver;
    
    endclass
    class monitor;
    
    endclass
    class scoreboard;
    
    endclass 
endpackage

//interface 
interface ram_inf;

endinterface 

 
module Sync_Dual_port_Ram_tb(

    );
endmodule
