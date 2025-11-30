// ============================================================================
// dct8_mem_bank.v
// --------------------------------------------------------------------------
// Simple dual-port memory bank for 8-point DCT intermediate storage.
//
// Parameterized by DATA_W and DEPTH (default 8).
// Both ports are synchronous read/write on the same clock.
// ============================================================================

`include "dct8_params.vh"

module dct8_mem_bank #(
    parameter DATA_W = DCT8_IN_W,
    parameter DEPTH  = 8,
    parameter ADDR_W = 3        // enough for DEPTH=8
)(
    input  wire                      clk,

    // Port A
    input  wire [ADDR_W-1:0]         addr_a,
    input  wire                      we_a,
    input  wire signed [DATA_W-1:0]  din_a,
    output reg  signed [DATA_W-1:0]  dout_a,

    // Port B
    input  wire [ADDR_W-1:0]         addr_b,
    input  wire                      we_b,
    input  wire signed [DATA_W-1:0]  din_b,
    output reg  signed [DATA_W-1:0]  dout_b
);

    // Memory array
    reg signed [DATA_W-1:0] mem [0:DEPTH-1];

    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = {DATA_W{1'b0}};
        end
    end

    // Port A
    always @(posedge clk) begin
        if (we_a) begin
            mem[addr_a] <= din_a;
        end
        dout_a <= mem[addr_a];
    end

    // Port B
    always @(posedge clk) begin
        if (we_b) begin
            mem[addr_b] <= din_b;
        end
        dout_b <= mem[addr_b];
    end

endmodule
