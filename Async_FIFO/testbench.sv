// testbench.sv
`timescale 1ns/1ps

module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    reg wr_clk, wr_rst_n, wr_en;
    reg [DATA_WIDTH-1:0] din;
    wire full;

    reg rd_clk, rd_rst_n, rd_en;
    wire [DATA_WIDTH-1:0] dout;
    wire empty;

    // Instantiate DUT
    async_fifo #(DATA_WIDTH, DEPTH) dut (
        .wr_clk(wr_clk), .wr_rst_n(wr_rst_n), .wr_en(wr_en), .din(din), .full(full),
        .rd_clk(rd_clk), .rd_rst_n(rd_rst_n), .rd_en(rd_en), .dout(dout), .empty(empty)
    );

    // --- Asynchronous Clock Generation ---
    // Write Clock: ~100 MHz (10ns period)
    always #5 wr_clk = ~wr_clk;
    
    // Read Clock: ~40 MHz (25ns period) - Much slower!
    always #12.5 rd_clk = ~rd_clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_async_fifo);

        // Initialize
        wr_clk = 0; rd_clk = 0;
        wr_rst_n = 0; rd_rst_n = 0;
        wr_en = 0; rd_en = 0; din = 0;

        // Apply Reset
        #30;
        wr_rst_n = 1; rd_rst_n = 1;
        $display("[%0t] Reset Complete", $time);

        // 1. Fast Write Burst
        $display("[%0t] Starting Fast Write Burst", $time);
        @(posedge wr_clk);
        for (int i = 0; i < DEPTH; i++) begin
            if (!full) begin
                wr_en = 1; 
                din = i + 8'hA0; // Write data A0, A1, A2...
                @(posedge wr_clk);
            end
        end
        wr_en = 0;

        // Give the synchronizers time to propagate the full/empty flags across domains
        #100; 

        // 2. Slow Read Burst
        $display("[%0t] Starting Slow Read Burst", $time);
        @(posedge rd_clk);
        for (int i = 0; i < DEPTH; i++) begin
            if (!empty) begin
                rd_en = 1;
                @(posedge rd_clk);
            end
        end
        rd_en = 0;

        #100;
        $display("[%0t] Simulation Complete", $time);
        $finish;
    end
endmodule