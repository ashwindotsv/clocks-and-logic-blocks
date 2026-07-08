`timescale 1ns / 1ps
/*
Synchronous FIFO (First-In First-Out) Buffer

Description:
This module implements a parameterized synchronous FIFO memory buffer.
Data is written and read using the same clock. The FIFO stores data in the
order it is received and outputs data in the same order (first in → first out).

Operation:
- Data is written into the FIFO when write enable (Wen) is high and FIFO is not FULL.
- Data is read from the FIFO when read enable (Ren) is high and FIFO is not EMPTY.
- Internal memory is organized as a circular buffer.
- Write and read pointers move forward on successful operations and wrap around
  when reaching the end of memory.

Status Signals:
- EMPTY: Asserted when no data is available to read.
- FULL : Asserted when FIFO cannot accept new data.

Design Notes:
- Extra MSB in pointers is used to distinguish FULL and EMPTY conditions.
- Lower pointer bits select memory address.
- This FIFO is fully synchronous (single clock domain).

Parameters:
- Depth : Number of storage locations in FIFO
- Width : Data width of each FIFO entry
*/

module sync_FIFO #(parameter Depth=8, Width= 16)(
    output reg [Width-1:0]Data_Out,
    input [Width-1:0] Data_In,
    input clk,RSTn,Wen, Ren,
    output FULL,EMPTY 
    );
    
    localparam Pointer_width = $clog2(Depth);
    reg [Pointer_width:0] w_ptr, r_ptr;
    reg [Width-1:0] FIFO [0:Depth-1];
    
    assign FULL=(w_ptr[Pointer_width] ^ r_ptr[Pointer_width])  && (w_ptr[Pointer_width-1:0] == r_ptr[Pointer_width-1:0]);
    assign EMPTY = (w_ptr== r_ptr);
    always @ (posedge clk or negedge RSTn)
    begin
        if (~RSTn)
        begin
            w_ptr <= 0;
            r_ptr <= 0;
            Data_Out <= 0;
        end
        else 
        begin
            if (Ren && ~EMPTY)
            begin 
                Data_Out <= FIFO[r_ptr[Pointer_width-1:0]];
                r_ptr <= r_ptr+1;
            end
            if (Wen && ~FULL)
            begin 
               FIFO[w_ptr[Pointer_width-1:0]] <= Data_In;
               w_ptr <= w_ptr+1;
            end
        end
    end
endmodule
