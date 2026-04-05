// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb_sync_fifo;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    // Testbench Signals
    reg clk;
    reg rst_n;
    reg wr_en;
    reg [DATA_WIDTH-1:0] din;
    reg rd_en;
    wire [DATA_WIDTH-1:0] dout;
    wire full, empty, almost_full, almost_empty;

    // Instantiate the Device Under Test (DUT)
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .din(din),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty)
    );

    // Clock Generation (100MHz)
    always #5 clk = ~clk;

    // --- Helper Tasks ---
    task write_data(input [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            wr_en = 1;
            din = data;
            @(posedge clk);
            wr_en = 0;
        end
    endtask

    task read_data();
        begin
            @(posedge clk);
            rd_en = 1;
            @(posedge clk);
            rd_en = 0;
        end
    endtask

    // --- Stimulus Block ---
    initial begin
        // Required for EDA Playground waveforms
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_sync_fifo);

        // Initialization
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        din = 0;
        rd_en = 0;

        // Apply Reset
        #15 rst_n = 1;
        $display("[%0t] Reset Deasserted", $time);

        // Test 1: Fill the FIFO
        $display("[%0t] --- Filling FIFO ---", $time);
        for (int i = 0; i < DEPTH; i++) begin
            write_data(i + 10); // Write arbitrary data
        end

        // Test 2: Try writing when full (Should not corrupt data)
        $display("[%0t] --- Testing Overflow Protection ---", $time);
        write_data(88); 

        // Test 3: Empty the FIFO
        $display("[%0t] --- Emptying FIFO ---", $time);
        for (int i = 0; i < DEPTH; i++) begin
            read_data();
        end

        // Test 4: Try reading when empty (Should not corrupt pointers)
        $display("[%0t] --- Testing Underflow Protection ---", $time);
        read_data(); 

        // Test 5: Concurrent Read and Write
        $display("[%0t] --- Concurrent Read & Write ---", $time);
        write_data(100);
        write_data(101);
        @(posedge clk);
        wr_en = 1; din = 102;
        rd_en = 1; // Read and write on the same clock edge
        @(posedge clk);
        wr_en = 0; rd_en = 0;

        // End simulation
        #50 $display("[%0t] Simulation Complete", $time);
        $finish;
    end

endmodule