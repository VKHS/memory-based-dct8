// ============================================================================
// cordic8.v
// --------------------------------------------------------------------------
// Top-level rotation block for 8-point DCT stages.
// Wraps cordic8_core with optional radius scaling (currently identity).
// ============================================================================

`include "dct8_params.vh"

module cordic8 #(
    parameter DATA_W   = DCT8_IN_W,
    parameter COEFF_W  = DCT8_COEFF_W,
    parameter FRACBITS = DCT8_FRAC_BITS
)(
    input  wire                     clk,
    input  wire                     rst_n,

    input  wire signed [DATA_W-1:0] x_in,
    input  wire signed [DATA_W-1:0] y_in,
    input  wire        [1:0]        angle_sel,

    output wire signed [DATA_W-1:0] x_out,
    output wire signed [DATA_W-1:0] y_out
);

    wire signed [DATA_W-1:0] x_scaled_in;
    wire signed [DATA_W-1:0] y_scaled_in;
    wire signed [DATA_W-1:0] x_rot;
    wire signed [DATA_W-1:0] y_rot;
    wire signed [DATA_W-1:0] x_scaled_out;
    wire signed [DATA_W-1:0] y_scaled_out;

    // Scale-up (currently identity)
    radius_scale8 #(
        .WIDTH(DATA_W)
    ) u_scale_up_x (
        .in_val (x_in),
        .out_val(x_scaled_in)
    );

    radius_scale8 #(
        .WIDTH(DATA_W)
    ) u_scale_up_y (
        .in_val (y_in),
        .out_val(y_scaled_in)
    );

    // Core rotation
    cordic8_core #(
        .DATA_W  (DATA_W),
        .COEFF_W (COEFF_W),
        .FRACBITS(FRACBITS)
    ) u_core (
        .x_in      (x_scaled_in),
        .y_in      (y_scaled_in),
        .angle_sel (angle_sel),
        .x_out     (x_rot),
        .y_out     (y_rot)
    );

    // Scale-down (currently identity)
    radius_scale8 #(
        .WIDTH(DATA_W)
    ) u_scale_down_x (
        .in_val (x_rot),
        .out_val(x_scaled_out)
    );

    radius_scale8 #(
        .WIDTH(DATA_W)
    ) u_scale_down_y (
        .in_val (y_rot),
        .out_val(y_scaled_out)
    );

    assign x_out = x_scaled_out;
    assign y_out = y_scaled_out;

endmodule
