// design.sv
module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16 // Must be power of 2
)(
    // Write Domain
    input  wire                  wr_clk,
    input  wire                  wr_rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] din,
    output wire                  full,

    // Read Domain
    input  wire                  rd_clk,
    input  wire                  rd_rst_n,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire                  empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Memory Array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers (Binary for memory addressing, Gray for CDC)
    reg [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray;
    reg [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_gray;

    // 2-Flop Synchronizer Registers
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;

    // --- WRITE LOGIC (wr_clk domain) ---
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;
            wr_ptr_bin  <= wr_ptr_bin + 1;
            // Binary to Gray Code conversion: Shift right by 1 and XOR
            wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);
        end
    end

    // --- READ LOGIC (rd_clk domain) ---
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
            dout        <= 0;
        end else if (rd_en && !empty) begin
            dout        <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
            rd_ptr_bin  <= rd_ptr_bin + 1;
            // Binary to Gray Code conversion
            rd_ptr_gray <= (rd_ptr_bin + 1) ^ ((rd_ptr_bin + 1) >> 1);
        end
    end

    // --- SYNCHRONIZERS ---
    // Pass Read Pointer into Write Domain
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1; // Safely in wr_clk domain
        end
    end

    // Pass Write Pointer into Read Domain
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1; // Safely in rd_clk domain
        end
    end

    // --- FLAG GENERATION ---
    // Empty: Read pointer caught up to synchronized write pointer
    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

    // Full: Write pointer wrapped around and caught synchronized read pointer.
    // In Gray code, a full wrap-around means the top 2 bits are inverted, the rest are identical.
    assign full = (wr_ptr_gray == {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

endmodule