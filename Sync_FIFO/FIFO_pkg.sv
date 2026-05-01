`timescale 1ns / 1ps

package fifo_pkg;

localparam  Depth = 8;
localparam  Width = 16;

    //transaction class 
    class fifo_transaction;
    
    rand logic Write_en,Read_en;
    rand  logic [Width-1:0] Data_ip;
        //read and write != 0 simaltaneously
        constraint data_pkt 
        {
        (Write_en || Read_en) == 1;
        // Add distribution to test various scenarios
//         Write_en dist {1 := 60, 0 := 40};  // 60% writes, 40% reads
//         Read_en  dist {1 := 40, 0 := 60};
        }
        //display
        function void display();
            $display("[%0t] | Wen = %0d | Ren = %0d | Input DATA  : %0d",$time, Write_en,Read_en,Data_ip);
        endfunction 
    endclass
    //generator class
    class fifo_generator;
        fifo_transaction tr;
        
        mailbox #(fifo_transaction) fifo_mail;//mailbox for IPC
        function new(mailbox #(fifo_transaction) mbox); // constructor
            fifo_mail = mbox;
        endfunction
         
        task gen_pkt; //generate random values 
            repeat (20)
            begin
                tr = new();
                tr.randomize();
                tr.display();
                fifo_mail.put(tr); 
            end 
        endtask 
    endclass
    //driver class
    class fifo_driver;
        fifo_transaction tr;
        mailbox #(fifo_transaction) fifo_mail; 
        
        virtual fifo_inf vir_if;//connect to interface  
        function new(mailbox #(fifo_transaction) mbox,virtual fifo_inf vif);
              fifo_mail = mbox;
              vir_if = vif;
        endfunction
        
        task drive_pkt;
        // initialize interface signals
            vir_if.Wen     = 0;
            vir_if.Ren     = 0;
            vir_if.Data_In = 0;
            wait(vir_if.RSTn);
            
             forever 
             begin
                  fifo_mail.get(tr);
                  // Apply inputs for one clock cycle
                  @(negedge vir_if.clk);
                  vir_if.Wen = tr.Write_en;
                  vir_if.Ren = tr.Read_en;
                  vir_if.Data_In = tr.Data_ip;
                  tr.display();
                  // Clear control signals next cycle 
                  @(posedge vir_if.clk);
                  vir_if.Wen=0;
                  vir_if.Ren=0;
             end 
        endtask
    endclass 
    
    class fifo_monitor;
        fifo_transaction tr;
        mailbox #(fifo_transaction) mon2scb;
        virtual fifo_inf vir_if;
        logic [Width-1:0] captured_data;
    
        function new(mailbox #(fifo_transaction) mbox, virtual fifo_inf vif);
            mon2scb = mbox;
            vir_if  = vif;
        endfunction
    
        task monitor_pkt;
            forever begin
                @(posedge vir_if.clk);
                 // Sample data at the clock edge
                 captured_data = vir_if.Data_In;
    
                // WRITE detection
                if (vir_if.Wen && !vir_if.FULL) begin
                    tr = new();
                    tr.Write_en = 1;
                    tr.Read_en  = 0;
                    tr.Data_ip  = captured_data;
                    mon2scb.put(tr);
                    $display("[MONITOR] WRITE: Data=%0d at %0t", captured_data, $time);
                end
    
                // READ detection
                if (vir_if.Ren && !vir_if.EMPTY) begin
                    @(posedge vir_if.clk);   // wait for read data
                    tr = new();
                    tr.Write_en = 0;
                    tr.Read_en  = 1;
                    tr.Data_ip  = vir_if.Data_Out;
                    mon2scb.put(tr);
                    $display("[MONITOR] READ: Data=%0d at %0t", vir_if.Data_Out, $time);
                end
            end
        endtask
    endclass
    
    class fifo_scoreboard;
        logic [Width-1:0] fifo_queue[$];
        mailbox #(fifo_transaction) mon2scb;
        fifo_transaction tr;
        logic [Width-1:0] expected;
        int pass_count, fail_count;
        
            function new(mailbox #(fifo_transaction) mbox);
                    mon2scb = mbox;
                    pass_count = 0;
                    fail_count = 0;
            endfunction
            
            task fifo_tester;
                forever 
                begin
                     mon2scb.get(tr);
                     
                     if(tr.Write_en)
                     begin
                        fifo_queue.push_back(tr.Data_ip);
                         $display("[SCOREBOARD] WRITTEN TO FIFO: %0d, Queue size: %0d",tr.Data_ip, fifo_queue.size());
                     end
                     
                     if(tr.Read_en)
                     begin
                        if (fifo_queue.size() == 0)
                        begin 
                            $display("[SCOREBOARD] ERROR: Can't Read when queue empty at %0t", $time);
                            fail_count++;
                        end
                     else
                        begin 
                            expected = fifo_queue.pop_front();
                            if (expected == tr.Data_ip)
                            begin
                                 $display("[SCOREBOARD] PASS: expected=%0d got=%0d at %0t",expected, tr.Data_ip, $time);
                                 pass_count++;
                            end
                            else 
                             begin
                                $display("[SCOREBOARD] FAIL: expected=%0d got=%0d at %0t",expected, tr.Data_ip, $time);
                                fail_count++;
                             end
                         end
                     end
                end
            endtask
            function void report();
                $display("SCOREBOARD REPORT:");
                $display("  PASSES: %0d", pass_count);                   
                $display("  FAILS:  %0d", fail_count);
           endfunction
        endclass  
endpackage