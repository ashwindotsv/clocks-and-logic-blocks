`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Example: Vending Machine Controller in Verilog - Design Description and Port Definition
//The vending machine sells bottles of water for 75¢. Customers can enter either a dollar bill
//or quarters. Once a sufficient amount of money is entered, the vending machine will
//dispense a bottle of water and, if the user entered a dollar, return one quarter in change.
//////////////////////////////////////////////////////////////////////////////////


module Vending_machine(
                       output reg  drop_bottle,change, 
                       input D_in,Q_in, CLK,RSTn
                       );
                       
   parameter [1:0] SRST=2'b00,S25=2'b01,S50=2'b10;
   reg [1:0]CS, NS;

always @ (posedge CLK or negedge RSTn)
    begin
    if (~RSTn)
    begin CS <= SRST; end 
    else
    begin CS <= NS; end
    end 


always @ *
    begin 
    case(CS)
    SRST: 
         if (Q_in == 1'b1)
            begin NS = S25; end
         else if (D_in == 1'b1)
            begin NS = SRST;  end        
         else 
            begin NS = SRST; end
     
     S25: 
         if (Q_in == 1'b1)
             begin NS = S50; end
         else if (D_in == 1'b1)
              begin NS = SRST;  end
          else 
             begin NS = S25; end
             
     S50:
        if (Q_in == 1'b1 || D_in == 1'b1)
                 begin NS = SRST; end
              else 
                 begin NS = S50; end
     
     default : NS = SRST; 
    endcase
    end
    
    
always @ *
    begin
        case(CS)
        SRST: 
            if(D_in == 1'b1)
                begin drop_bottle=1'b1; change = 1'b1; end
            else 
                 begin drop_bottle=1'b0; change = 1'b0; end
        
        S25:
             if(D_in == 1'b1)
                 begin drop_bottle=1'b1; change = 1'b1; end
             else
                 begin drop_bottle=1'b0; change = 1'b0; end
        S50:
            if(Q_in == 1'b1)
                 begin drop_bottle=1'b1; change = 1'b0; end
            else  if(D_in == 1'b1)
                 begin drop_bottle=1'b1; change = 1'b1; end
             else
                 begin drop_bottle=1'b0; change = 1'b0; end
        endcase
    end    
    
endmodule




// testbench
module VM_TB();
wire drop_bottle,change; 
reg D_in=0,Q_in=0, CLK=0,RSTn=0;

 Vending_machine dut (
       .drop_bottle(drop_bottle),
       .change(change),
       .D_in(D_in),
       .Q_in(Q_in),
       .CLK(CLK),
       .RSTn(RSTn)
   );

always #5 CLK =~CLK;

initial 
begin 
 $monitor(
           "Time=%0t | D=%b | Q=%b | drop=%b | change=%b | state=%b",
            $time, D_in, Q_in, drop_bottle, change, dut.CS
       );
#10 RSTn = 1;

#10 D_in = 1; #10 D_in = 0;

#40 Q_in = 1; #10 Q_in = 0;
#40 D_in = 1; #10 D_in = 0;

#30 Q_in = 1; #10 Q_in = 0;
#30 Q_in = 1; #10 Q_in = 0;
#30 Q_in = 1; #10 Q_in = 0;

#30;
$stop;
end
endmodule 