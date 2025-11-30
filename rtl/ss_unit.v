// ============================================================================
// ss_unit.v
// --------------------------------------------------------------------------
// Safe-scaling unit.
// - Performs a fixed left shift (logical) on a signed value.
// - Intended to prevent overflow / manage dynamic range in butterfly stages.
//
// No saturation here (truncation on overflow). You can add saturation logic
// if needed later.
// ============================================================================

module ss_unit #(
    parameter WIDTH = 16,
    parameter SHIFT = 1
)(
    input  wire signed [WIDTH-1:0] din,
    output wire signed [WIDTH-1:0] dout
);

    // Simple left shift by SHIFT bits
    assign dout = din <<< SHIFT;

endmodule
