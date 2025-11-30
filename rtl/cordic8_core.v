// ============================================================================
// cordic8_core.v
// --------------------------------------------------------------------------
// Core rotation block for 8-point DCT stages using fixed angles:
//   angle_sel = 2'b00 -> pi/16
//   angle_sel = 2'b01 -> pi/8
//   angle_sel = 2'b10 -> 3*pi/16
//
// Currently implemented as a direct cos/sin multiplier-based rotator
// (Q1.15 coefficients). You can replace this with an iterative CORDIC
// engine later without changing the interface.
// ============================================================================

`include "dct8_params.vh"

module cordic8_core #(
    parameter DATA_W   = DCT8_IN_W,
    parameter COEFF_W  = DCT8_COEFF_W,
    parameter FRACBITS = DCT8_FRAC_BITS
)(
    input  wire signed [DATA_W-1:0]  x_in,
    input  wire signed [DATA_W-1:0]  y_in,
    input  wire        [1:0]         angle_sel,

    output wire signed [DATA_W-1:0]  x_out,
    output wire signed [DATA_W-1:0]  y_out
);

    // Q1.15 constants for cos/sin of pi/16, pi/8, 3*pi/16
    // cos(pi/16)  ≈ 0.98078528  -> 32138
    // sin(pi/16)  ≈ 0.19509032  -> 6393
    // cos(pi/8)   ≈ 0.92387953  -> 30274
    // sin(pi/8)   ≈ 0.38268343  -> 12540
    // cos(3pi/16) ≈ 0.83146961  -> 27246
    // sin(3pi/16) ≈ 0.55557023  -> 18205

    localparam signed [COEFF_W-1:0] COS_PI_16   = 16'sd32138;
    localparam signed [COEFF_W-1:0] SIN_PI_16   = 16'sd6393;
    localparam signed [COEFF_W-1:0] COS_PI_8    = 16'sd30274;
    localparam signed [COEFF_W-1:0] SIN_PI_8    = 16'sd12540;
    localparam signed [COEFF_W-1:0] COS_3PI_16  = 16'sd27246;
    localparam signed [COEFF_W-1:0] SIN_3PI_16  = 16'sd18205;

    reg signed [COEFF_W-1:0] cos_k;
    reg signed [COEFF_W-1:0] sin_k;

    always @(*) begin
        case (angle_sel)
            2'b00: begin
                cos_k = COS_PI_16;
                sin_k = SIN_PI_16;
            end
            2'b01: begin
                cos_k = COS_PI_8;
                sin_k = SIN_PI_8;
            end
            2'b10: begin
                cos_k = COS_3PI_16;
                sin_k = SIN_3PI_16;
            end
            default: begin
                cos_k = COS_PI_16;
                sin_k = SIN_PI_16;
            end
        endcase
    end

    localparam PROD_W = DATA_W + COEFF_W;

    // Products
    wire signed [PROD_W-1:0] x_cos = x_in * cos_k;
    wire signed [PROD_W-1:0] y_sin = y_in * sin_k;
    wire signed [PROD_W-1:0] x_sin = x_in * sin_k;
    wire signed [PROD_W-1:0] y_cos = y_in * cos_k;

    // Rotate:
    // x' = x*cos - y*sin
    // y' = x*sin + y*cos
    wire signed [PROD_W:0] x_tmp = x_cos - y_sin;
    wire signed [PROD_W:0] y_tmp = x_sin + y_cos;

    assign x_out = x_tmp >>> FRACBITS;
    assign y_out = y_tmp >>> FRACBITS;

endmodule
