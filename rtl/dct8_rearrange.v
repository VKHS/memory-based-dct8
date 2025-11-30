// ============================================================================
// dct8_rearrange.v
// --------------------------------------------------------------------------
// Rearrange unit skeleton for stages using a rotation (e.g., CORDIC).
//
// For now, it simply passes memory read data directly into the "rotation"
// block inputs, and passes the rotation outputs back as memory write data.
// Later you can add stage-dependent swaps, sign changes, etc.
// ============================================================================

`include "dct8_params.vh"

module dct8_rearrange #(
    parameter DATA_W = DCT8_IN_W
)(
    input  wire                     clk,
    input  wire                     rst_n,

    // Data from memory (two values)
    input  wire signed [DATA_W-1:0] mem_rdata_a,
    input  wire signed [DATA_W-1:0] mem_rdata_b,

    // Data to rotation block (e.g., CORDIC)
    output reg  signed [DATA_W-1:0] rot_x_in,
    output reg  signed [DATA_W-1:0] rot_y_in,

    // Data from rotation block
    input  wire signed [DATA_W-1:0] rot_x_out,
    input  wire signed [DATA_W-1:0] rot_y_out,

    // Data to be written back to memory
    output reg  signed [DATA_W-1:0] mem_wdata_a,
    output reg  signed [DATA_W-1:0] mem_wdata_b
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rot_x_in    <= {DATA_W{1'b0}};
            rot_y_in    <= {DATA_W{1'b0}};
            mem_wdata_a <= {DATA_W{1'b0}};
            mem_wdata_b <= {DATA_W{1'b0}};
        end else begin
            // For now: direct mapping (no complex reordering yet)
            rot_x_in    <= mem_rdata_a;
            rot_y_in    <= mem_rdata_b;
            mem_wdata_a <= rot_x_out;
            mem_wdata_b <= rot_y_out;
        end
    end

endmodule
