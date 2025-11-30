// ============================================================================
// dct8_top.v
// --------------------------------------------------------------------------
// Public top-level 8-point DCT module.
// For Rev-1, simply wraps the streaming core (dct8_stream).
// ============================================================================

`include "dct8_params.vh"

module dct8_top #(
    parameter N         = DCT8_N,
    parameter IN_W      = DCT8_IN_W,
    parameter COEFF_W   = DCT8_COEFF_W,
    parameter OUT_W     = DCT8_OUT_W,
    parameter FRAC_BITS = DCT8_FRAC_BITS
)(
    input  wire                    clk,
    input  wire                    rst_n,

    // Input sample stream (one sample per cycle)
    input  wire                    din_valid,
    input  wire signed [IN_W-1:0]  din,
    output wire                    din_ready,

    // Output coefficient stream (one coeff per cycle)
    output wire                    dout_valid,
    output wire signed [OUT_W-1:0] dout,
    input  wire                    dout_ready
);

    // NOTE:
    // This top-level assumes you also have dct8_stream.v, dct8_block.v,
    // and dct8_kernel_comb.v in your rtl/ folder (we wrote those already).
    // Here we just hook them up via dct8_stream.

    dct8_stream #(
        .N        (N),
        .IN_W     (IN_W),
        .COEFF_W  (COEFF_W),
        .OUT_W    (OUT_W),
        .FRAC_BITS(FRAC_BITS)
    ) u_stream (
        .clk        (clk),
        .rst_n      (rst_n),
        .din_valid  (din_valid),
        .din        (din),
        .din_ready  (din_ready),
        .dout_valid (dout_valid),
        .dout       (dout),
        .dout_ready (dout_ready)
    );

endmodule
