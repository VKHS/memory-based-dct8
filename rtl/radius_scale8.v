// ============================================================================
// radius_scale8.v
// --------------------------------------------------------------------------
// Radius scaling stub for 8-point CORDIC block.
// Currently implemented as identity (no scaling).
// You can replace the assignment with shift/add logic to approximate
// the desired 1/K factor and DCT normalization.
// ============================================================================

module radius_scale8 #(
    parameter WIDTH = 16
)(
    input  wire signed [WIDTH-1:0] in_val,
    output wire signed [WIDTH-1:0] out_val
);

    assign out_val = in_val;

endmodule
