// ============================================================================
// butterfly8.v
// --------------------------------------------------------------------------
// Simple butterfly processing element for 8-point DCT stages.
// Computes sum and difference of two inputs with optional safe scaling.
//
//   out_sum  = ss_unit(sum)
//   out_diff = ss_unit(diff)
//
// You can extend this later with more complex internal feedback, etc.
// ============================================================================

`include "dct8_params.vh"

module butterfly8 #(
    parameter DATA_W = DCT8_IN_W
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     enable,

    input  wire signed [DATA_W-1:0] in_a,
    input  wire signed [DATA_W-1:0] in_b,

    output reg  signed [DATA_W-1:0] out_sum,
    output reg  signed [DATA_W-1:0] out_diff
);

    wire signed [DATA_W-1:0] sum;
    wire signed [DATA_W-1:0] diff;

    wire signed [DATA_W-1:0] sum_scaled;
    wire signed [DATA_W-1:0] diff_scaled;

    assign sum  = in_a + in_b;
    assign diff = in_a - in_b;

    // Safe-scaling: left shift by 1 bit (factor of 2) by default
    ss_unit #(
        .WIDTH(DATA_W),
        .SHIFT(1)
    ) u_ss_sum (
        .din (sum),
        .dout(sum_scaled)
    );

    ss_unit #(
        .WIDTH(DATA_W),
        .SHIFT(1)
    ) u_ss_diff (
        .din (diff),
        .dout(diff_scaled)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_sum  <= {DATA_W{1'b0}};
            out_diff <= {DATA_W{1'b0}};
        end else begin
            if (enable) begin
                out_sum  <= sum_scaled;
                out_diff <= diff_scaled;
            end
        end
    end

endmodule
