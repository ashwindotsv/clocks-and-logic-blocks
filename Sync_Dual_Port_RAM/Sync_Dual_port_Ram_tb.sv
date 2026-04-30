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

//interface 
interface DP_ram_inf #(parameter Width=8,Depth=32 );
                     logic clk, RSTn;
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
                                    
                  
                  property reset_check; // if RSTn =0; o/p data = 0 next cycle (sync behaviour)
                        @(posedge clk) (!RSTn) |=> (Data_Out_A == 0 && Data_Out_B == 0);
                  endproperty
                  assert property(reset_check) 
                    else $display("!!! RESET ASSERTION FAILED !!!");
                  
                  property collision;
                        @(posedge clk) (A_en && We_A &&  B_en && We_B && (Address_A == Address_B)) |=> ( Data_Out_B == $past(Data_Out_B));
                  endproperty
                  assert property (collision) 
                    else $display("COLLISION DETECTED - PORT A WINS!!!");
    
endinterface 

package dual_port_ram;

localparam  Width=8;
localparam Depth=32;

    class transaction;
    
        rand logic [Width-1:0] Data_In_A,Data_In_B; //i/p signals
        rand bit A_en,We_A, Re_A,B_en,We_B, Re_B; // enable signals
        rand logic [$clog2(Depth)-1:0] Address_A, Address_B; //address signals 
        logic [Width-1:0] Data_Out_A, Data_Out_B;//O/P signals
        
        constraint valid_addr {
            Address_A < Depth;
            Address_B < Depth;
        }// to make addresses stay within valid range
        
        function void display();//display function
            $display("\n---------------------I/P Packet--------------------\n");
            $display("[%0t] | TRANSACTION PACKET - PORT A \n  A_en = %0d | We_A = %0d | Re_A : %0d \n ", $time, A_en,We_A, Re_A);
            
            $display("[%0t] | TRANSACTION PACKET PORT B:\n B_en = %0d | We_B = %0d | Re_B :%0d\n",$time,B_en,We_B, Re_B);    
                
            $display("[%0t] | DATA_IN_A : %d | DATA_IN_B : %d\n Address of PORT A :%d| Address of PORT B :%d\n",$time,Data_In_A,Data_In_B,Address_A, Address_B);
            $display("\n---------------------END OF I/P Packet--------------------\n");
        endfunction 
        
        function void show();
            $display("OUTPUT DATA @ [%0t] | DATA_OUT_A : %d | DATA_OUT_B : %d\n",$time,Data_Out_A,Data_Out_B);
        endfunction 
        
    endclass
    
    class generator;
    
        mailbox RAM_mail;// mailbox between generator and driver.
        transaction txn;// transaction handle 
       
        function new(); //constructor
            txn = new();
            RAM_mail = new();
        endfunction
         
        task gen_txn(); // loop to generate random transactions and put into mailbox.
            repeat(20)
            begin
                txn = new(); //gen new obj everytime
                txn.randomize();//randomize
                RAM_mail.put(txn);//put into mailbox
                txn.display();  //display
            end
        endtask
        
    endclass
    
    class driver;
    
        mailbox RAM_mail;// mailbox between generator and driver.
        transaction txn;// transaction handle
        virtual DP_ram_inf #(8,32) vir_if;
        
        task dri_txn();
            repeat(20)
            begin
                 RAM_mail.get(txn);
                 @(posedge vir_if.clk);
                 vir_if.A_en = txn.A_en;
                 vir_if.B_en = txn.B_en;
                 vir_if.We_A = txn.We_A;
                 vir_if.We_B = txn.We_B;
                 vir_if.Re_A = txn.Re_A;
                 vir_if.Re_B = txn.Re_B;
                 vir_if.Address_A = txn.Address_A;
                 vir_if.Address_B = txn.Address_B; 
                 vir_if.Data_In_A = txn.Data_In_A;
                 vir_if.Data_In_B = txn.Data_In_B;
            end
        endtask 
        
    endclass
    
    class monitor;
    
        covergroup cover_RAM;
            
        endgroup
        transaction txn;
        mailbox RAM_mailbox;//mailbox between monitor and scoreboard 
        virtual DP_ram_inf #(8,32) vir_if;
        
            function new();//constructor
                RAM_mailbox =new();
            endfunction 

            task put_txn; //put to scoreboard
                repeat(20)
                begin
                    @(posedge vir_if.clk);//sample at posedge 
                    txn = new();
                    txn.Data_Out_A = vir_if.Data_Out_A;
                    txn.Data_Out_B = vir_if.Data_Out_B;
                    txn.A_en = vir_if.A_en;
                    txn.B_en = vir_if.B_en;
                    txn.We_A = vir_if.We_A;
                    txn.We_B = vir_if.We_B;
                    txn.Re_A = vir_if.Re_A;
                    txn.Re_B = vir_if.Re_B;
                    txn.Address_A = vir_if.Address_A;
                    txn.Address_B = vir_if.Address_B; 
                    txn.Data_In_A = vir_if.Data_In_A;
                    txn.Data_In_B = vir_if.Data_In_B;
                    //@(posedge vir_if.clk);//next posedge put to scoreboard
                    RAM_mailbox.put(txn);
                    txn.show();
                end
            endtask
            
    endclass
    
    class scoreboard;
   
        transaction txn;
        mailbox RAM_mailbox;//mailbox between monitor and scoreboard 
        logic [Width-1:0] mem_model [int];// Associative array as RAM model
        
        function new();
            RAM_mailbox = new();
        endfunction 
        
        task get_txn;
            repeat (20)
            begin
                RAM_mailbox.get(txn);
                //collision condition
                $display("------------[%0t] SCOREBOARD RESULT---------------", $time);
                if (txn.A_en && txn.B_en && txn.We_A && txn.We_B && txn.Address_A == txn.Address_B)
                begin
                    mem_model[txn.Address_A] = txn.Data_In_A;
                    $display("COLLISION - PORT A WINS : Expected - %d | Data_Out - %d \n",mem_model[txn.Address_A],txn.Data_Out_A);
                end
                //handle port A 
                else
                begin
                    if (txn.A_en && txn.We_A)
                    begin
                        mem_model[txn.Address_A] = txn.Data_In_A;
                        $display("PORT A WRITE : Addr[%0d] = %0d", txn.Address_A, txn.Data_In_A); 
                    end
                    else if (txn.A_en && txn.Re_A)
                    begin
                        if (mem_model.exists(txn.Address_A))
                        begin
                            if ( mem_model[txn.Address_A] == txn.Data_Out_A)
                            begin                        
                                $display("*** PASS *** PORT A READ | Addr[%0d] | Expected: %0d | Got: %0d\n",txn.Address_A, mem_model[txn.Address_A], txn.Data_Out_A);
                            end
                            else
                            begin
                               $display("!!! FAIL !!! PORT A READ | Addr[%0d] | Expected: %0d | Got: %0d\n",txn.Address_A, mem_model[txn.Address_A], txn.Data_Out_A);
                            end
                        end
                    end
                    //HANDLE PORT B
                    if (txn.B_en && txn.We_B)
                    begin 
                        mem_model[txn.Address_B] = txn.Data_In_B;
                        $display("PORT B WRITE : Addr[%0d] = %0d", txn.Address_B, txn.Data_In_B);
                    end  
                    else if (txn.B_en && txn.Re_B) 
                    begin
                        if (mem_model.exists(txn.Address_B))
                        begin
                            if ( mem_model[txn.Address_B] == txn.Data_Out_B)
                            begin
                                $display("*** PASS *** PORT B READ | Addr[%0d] | Expected: %0d | Got: %0d\n",txn.Address_B, mem_model[txn.Address_B], txn.Data_Out_B);
                            end
                            else
                            begin
                                $display("!!! FAIL !!! PORT B READ | Addr[%0d] | Expected: %0d | Got: %0d\n",txn.Address_B, mem_model[txn.Address_B], txn.Data_Out_B);
                            end
                        end
                    end                   
                end
            end
        endtask
    endclass
     
endpackage

import dual_port_ram::*; //import the package

module Sync_Dual_port_Ram_tb();

    reg clk = 0;
    reg RSTn = 0; // declare the signals which arent controlled by RAM (foreign signals)
    
    DP_ram_inf #(8,32) ram_if();//virtual interface declaration
    assign ram_if.clk = clk;
    assign ram_if.RSTn = RSTn;
    
    Sync_Dual_port_RAM #(8,32) DUT(
                                .clk(ram_if.clk),.RSTn(ram_if.RSTn),
                                .A_en(ram_if.A_en),.We_A(ram_if.We_A),.Re_A(ram_if.Re_A),
                                .B_en(ram_if.B_en),.We_B(ram_if.We_B),.Re_B(ram_if.Re_B),
                                .Data_In_A(ram_if.Data_In_A),.Data_In_B(ram_if.Data_In_B),
                                .Address_A(ram_if.Address_A),.Address_B(ram_if.Address_B),
                                .Data_Out_A(ram_if.Data_Out_A),.Data_Out_B(ram_if.Data_Out_B)
                                ); //intsantiate the DUT through interface 
                                
                                always #5 clk = ~clk; //clock generation
                                initial
                                begin
                                    RSTn = 0;
                                    #20;
                                    RSTn = 1;
                                end
                                initial
                                begin
                                    //create handles 
                                    static generator gen = new();
                                    static driver dri = new();
                                    static monitor mon = new();
                                    static scoreboard scb = new();
                                    static mailbox gen_dri_mail = new();
                                    static mailbox mon_scb_mail = new();
                                    
                                    mon.RAM_mailbox = mon_scb_mail;
                                    scb.RAM_mailbox = mon_scb_mail;
                                    
                                    dri.vir_if = ram_if;
                                    mon.vir_if = ram_if;
                                    
                                    
                                    gen.RAM_mail = gen_dri_mail;
                                    dri.RAM_mail = gen_dri_mail;
                                    @(posedge ram_if.RSTn);
                                    //parallel process
                                    fork
                                        gen.gen_txn();
                                        dri.dri_txn();
                                        mon.put_txn();    
                                        scb.get_txn();    
                                    join
                                    $finish;
                                end
endmodule