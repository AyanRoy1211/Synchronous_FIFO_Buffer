// design.sv
module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    // Thresholds for flow control (AXI/Pipelining)
    parameter ALMOST_FULL_THRESH = 14, 
    parameter ALMOST_EMPTY_THRESH = 2
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty,
    output wire                  almost_full,
    output wire                  almost_empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers (1 bit wider than address for wrap-around detection)
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;

    // Calculate current item count
    wire [ADDR_WIDTH:0] count;
    assign count = wr_ptr - rd_ptr;

    // Flag Generation
    assign empty        = (count == 0);
    assign full         = (count == DEPTH);
    assign almost_empty = (count <= ALMOST_EMPTY_THRESH);
    assign almost_full  = (count >= ALMOST_FULL_THRESH);

    // Write Logic (No reset here encourages BRAM inference in synthesis)
    always @(posedge clk) begin
        if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= din;
        end
    end

    // Read and Pointer Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            dout   <= 0;
        end else begin
            // Write pointer increment
            if (wr_en && !full) begin
                wr_ptr <= wr_ptr + 1;
            end
            
            // Read pointer increment & data output
            if (rd_en && !empty) begin
                dout   <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr <= rd_ptr + 1;
            end
        end
    end

endmodule