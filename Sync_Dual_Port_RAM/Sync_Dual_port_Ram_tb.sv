`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ashwin Nayak
// 
// Create Date: 21.04.2026 14:24:17
// Design Name: 
// Module Name: Sync_Dual_port_Ram_tb
// Project Name: Sync_Dual_port_RAM
//
// Description: 
// 
// 
// 
// 
// 
//////////////////////////////////////////////////////////////////////////////////
package dual_port_ram;

localparam  Width=8;
localparam Depth=32;

    class transaction;
    rand logic [Width-1:0] Data_In_A,Data_In_B; //i/p signals
    rand bit A_en,We_A, Re_A,B_en,We_B, Re_B; // enable signals
    rand logic [$clog2(Depth)-1:0] Address_A, Address_B; //address signals 
    
    constraint valid_addr {
        Address_A < Depth;
        Address_B < Depth;
    }// to make addresses stay within valid range
    
    function void display();//display function
        $display("[%0t] | TRANSACTION PACKET - PORT A \n  A_en = %0d | We_A = %0d | Re_A : %0d \n ", $time, A_en,We_A, Re_A);
        
        $display("[%0t] | TRANSACTION PACKET PORT B:\n B_en = %0d | We_B = %0d | Re_B :",$time,B_en,We_B, Re_B);    
            
        $display("[%0t] | DATA_IN_A : %d | DATA_IN_B : %d",$time,Data_In_A,Data_In_B);
    endfunction 
    
    endclass
    
    class generator;
    
        mailbox RAM_mail;// mailbox between generator and driver.
        transaction txn;// transaction handle 
       
        function new(); //constructor
            txn = new();
            RAM_mail = new();
        endfunction
         
        function void gen_txn(); // loop to generate random transactions and put into mailbox.
            repeat(20)
            begin
                txn = new(); //gen new obj everytime
                txn.randomize();//randomize
                RAM_mail.put(txn);//put into mailbox
                txn.display();  //display
            end
        endfunction  
    endclass
    
    class driver;
        mailbox RAM_mail;// mailbox between generator and driver.
        transaction txn;// transaction handle 
       
        function new(); //constructor
            txn = new();
            RAM_mail = new();
        endfunction
    endclass
    
    class monitor;
    covergroup cover_RAM;
    
    endgroup
    endclass
    
    class scoreboard;
    
    endclass
     
endpackage

//interface 
interface DP_ram_inf #(parameter Width=8,Depth=32 )(
                     input bit clk, RSTn
                     );
                     logic A_en, We_A, Re_A;
                     logic B_en, We_B, Re_B;
                     logic [$clog2(Depth)-1:0] Address_A, Address_B;
                     logic [Width-1:0] Data_In_A, Data_In_B;
                     logic [Width-1:0] Data_Out_A, Data_Out_B;
                     
                    modport driver (input clk, input RSTn,
                                    output  A_en, We_A, Re_A, B_en, We_B, Re_B,
                                    output Data_In_A, Data_In_B,
                                    output  Address_A, Address_B); 
                    modport monitor (input clk, input RSTn,
                                    input Data_Out_A, Data_Out_B,
                                    input  A_en, We_A, Re_A, B_en, We_B, Re_B,
                                    input  Data_In_A, Data_In_B,
                                    input  Address_A, Address_B);
    
endinterface 

 
module Sync_Dual_port_Ram_tb(

    );
endmodule
