`timescale 1ns / 1ps

module Traffic_light_controller(
    output reg NSR, NSY, NSG, EWR, EWY, EWG,
    input TEW, CLK, RSTn
);

localparam [1:0] IDLE = 2'b00,
                 TRAFFIC_DETECTED = 2'b01,
                 ALLOW_TRAFFIC = 2'b10,
                 NO_TRAFFIC = 2'b11;

reg [1:0] CS_NS, NEXT_NS, CS_EW, NEXT_EW;
wire CLK_4HZ;

CLK_DIV_N #(.N(10)) MOD1 (.CLK_FPGA(CLK), .CLK_MOD(CLK_4HZ), .RSTn(RSTn));

always @(posedge CLK_4HZ or negedge RSTn) begin
    if (~RSTn) begin
        CS_NS <= IDLE;
        CS_EW <= IDLE;
    end else begin
        CS_NS <= NEXT_NS;
        CS_EW <= NEXT_EW;
    end
end

always @* begin
    NEXT_EW = CS_EW;
    case (CS_EW)
        IDLE: begin
            if (TEW === 1'b1)
                NEXT_EW = TRAFFIC_DETECTED;
            else
                NEXT_EW = IDLE;
        end

        TRAFFIC_DETECTED: begin
            if (TEW === 1'b1)
                NEXT_EW = ALLOW_TRAFFIC;
            else
                NEXT_EW = IDLE;
        end

        ALLOW_TRAFFIC: begin
            if (TEW === 1'b1)
                NEXT_EW = ALLOW_TRAFFIC;
            else
                NEXT_EW = NO_TRAFFIC;
        end

        NO_TRAFFIC: begin
            if (TEW === 1'b0)
                NEXT_EW = IDLE;
            else
                NEXT_EW = ALLOW_TRAFFIC;
        end
    endcase
end

always @* begin
    NEXT_NS = CS_NS;
    case (CS_NS)
        IDLE: begin
            if (TEW === 1'b1)
                NEXT_NS = TRAFFIC_DETECTED;
            else
                NEXT_NS = IDLE;
        end

        TRAFFIC_DETECTED: begin
            if (TEW === 1'b1)
                NEXT_NS = ALLOW_TRAFFIC;
            else
                NEXT_NS = IDLE;
        end

        ALLOW_TRAFFIC: begin
            if (TEW === 1'b1)
                NEXT_NS = ALLOW_TRAFFIC;
            else
                NEXT_NS = NO_TRAFFIC;
        end

        NO_TRAFFIC: begin
            if (TEW === 1'b0)
                NEXT_NS = IDLE;
            else
                NEXT_NS = ALLOW_TRAFFIC;
        end
    endcase
end

always @* begin
 NSR = 0; NSY = 0; NSG = 0;EWR = 0; EWY = 0; EWG = 0;

    case (CS_NS)
        IDLE: NSG = 1;
        TRAFFIC_DETECTED: NSY = 1;
        ALLOW_TRAFFIC: NSR = 1;
        NO_TRAFFIC: NSG = 1;
    endcase

    case (CS_EW)
        IDLE: EWR = 1;
        TRAFFIC_DETECTED: EWY = 1;
        ALLOW_TRAFFIC: EWG = 1;
        NO_TRAFFIC: EWR = 1;
    endcase
end

endmodule
/// above code created two FSMS and they are not coordinated.



///TESTBENCHH

module TLTB();
    reg CLK;
    reg RSTn;
    reg TEW;
    wire NSR, NSY, NSG, EWR, EWY, EWG;

Traffic_light_controller TBMOD(.CLK(CLK),.RSTn(RSTn),.TEW(TEW),.NSR(NSR),.NSY(NSY),.NSG(NSG),.EWR(EWR),.EWY(EWY),.EWG(EWG));

always #5 CLK = ~CLK;

initial 
begin 
    CLK=0; RSTn = 0; TEW =0;
    
    #20 RSTn = 1;
    #20000 TEW = 1;
    #20000 TEW = 0;
    #20000;
    $finish;
end 
endmodule 