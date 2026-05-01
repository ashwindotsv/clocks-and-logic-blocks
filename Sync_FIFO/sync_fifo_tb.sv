`timescale 1ns / 1ps
interface fifo_inf(input bit clk);
    parameter Width = 16;
    logic RSTn,Wen,Ren,FULL,EMPTY;
    logic [Width-1:0] Data_Out;
    logic [Width-1:0] Data_In;
    
    property no_write_when_full;
        @(posedge clk)
        FULL |-> !Wen;
    endproperty 
    
    property no_read_when_empty;
        @(posedge clk) disable iff(!RSTn)
        EMPTY |-> !Ren;
    endproperty 
    
    property full_empty_together_invalid;
        @(posedge clk)
        !(FULL && EMPTY);
    endproperty   
    
    assert property(no_write_when_full)
    else $error("ASSERTION FAILED: Write attempted when FIFO FULL");
    
    assert property(no_read_when_empty)
    else $error("ASSERTION FAILED: Read attempted when FIFO EMPTY");
    
    assert property(full_empty_together_invalid)
    else $error("ASSERTION FAILED: FIFO cannot be FULL and EMPTY simultaneously");  
endinterface 

module sync_fifo_tb();

//define parameters
    parameter Depth = 8;
    parameter Width = 16;
    bit clk;
    
//instantiate interface
fifo_inf #(Width) fifo_if(clk);

//instantiate module 
sync_FIFO #(.Depth(Depth), .Width(Width)) DUT (
   .clk(clk),
   .RSTn(fifo_if.RSTn),
   .Wen(fifo_if.Wen),
   .Ren(fifo_if.Ren),
   .Data_In(fifo_if.Data_In),
   .Data_Out(fifo_if.Data_Out),
   .FULL(fifo_if.FULL),
   .EMPTY(fifo_if.EMPTY)
);
//clock generation
initial clk=0;
always #5 clk = ~clk;

initial 
    begin
        import fifo_pkg::*;
        mailbox #(fifo_transaction) mbx;
        mailbox #(fifo_transaction) mon2scb;
        fifo_generator gen;
        fifo_driver dri;
        fifo_monitor mon;
        fifo_scoreboard scb;
        
        mbx = new();
        mon2scb = new();
        gen = new(mbx);
        dri = new(mbx,fifo_if);
        mon = new(mon2scb,fifo_if);
        scb = new(mon2scb);
        
        // Reset sequence
        fifo_if.RSTn = 0;
        repeat(5) @(posedge clk);
        fifo_if.RSTn = 1;
        @(posedge clk);
        
        fork 
            gen.gen_pkt;
            dri.drive_pkt;
            mon.monitor_pkt;
            scb.fifo_tester;
        join_any 
        
        repeat(100) @(posedge clk);
        scb.report();
        $finish;
    end
endmodule