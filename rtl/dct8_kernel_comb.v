// ============================================================================
// dct8_kernel_comb.v
// --------------------------------------------------------------------------
// Pure combinational 8-point DCT-II kernel.
// - Inputs:  8 signed samples (IN_W bits each)
// - Outputs: 8 signed DCT coefficients (OUT_W bits each)
// - Coefficients: orthonormal DCT-II, Q1.15 fixed-point
//
// SystemVerilog syntax (always_comb, packed arrays), but can be saved as .v
// ============================================================================

module dct8_kernel_comb #(
    parameter int N         = 8,
    parameter int IN_W      = 16,   // input sample width
    parameter int COEFF_W   = 16,   // coefficient width (Q1.15)
    parameter int OUT_W     = 16,   // output width
    parameter int FRAC_BITS = 15    // fractional bits in coefficients
)(
    // 8 input samples
    input  logic signed [IN_W-1:0] x0,
    input  logic signed [IN_W-1:0] x1,
    input  logic signed [IN_W-1:0] x2,
    input  logic signed [IN_W-1:0] x3,
    input  logic signed [IN_W-1:0] x4,
    input  logic signed [IN_W-1:0] x5,
    input  logic signed [IN_W-1:0] x6,
    input  logic signed [IN_W-1:0] x7,

    // 8 DCT coefficients
    output logic signed [OUT_W-1:0] X0,
    output logic signed [OUT_W-1:0] X1,
    output logic signed [OUT_W-1:0] X2,
    output logic signed [OUT_W-1:0] X3,
    output logic signed [OUT_W-1:0] X4,
    output logic signed [OUT_W-1:0] X5,
    output logic signed [OUT_W-1:0] X6,
    output logic signed [OUT_W-1:0] X7
);

    // Pack inputs into an array for easy looping
    logic signed [IN_W-1:0] x   [0:N-1];

    // Internal accumulators – wider to avoid overflow
    localparam int ACC_W = IN_W + COEFF_W + $clog2(N);
    logic signed [ACC_W-1:0] acc [0:N-1];

    // Internal outputs before assigning to ports
    logic signed [OUT_W-1:0] X_int [0:N-1];

    // DCT coefficient matrix (orthonormal, Q1.15)
    localparam logic signed [COEFF_W-1:0] COS_LUT [0:N-1][0:N-1] = '{
        // k = 0
        '{ 16'sd11585, 16'sd11585, 16'sd11585, 16'sd11585,
           16'sd11585, 16'sd11585, 16'sd11585, 16'sd11585 },

        // k = 1
        '{ 16'sd16069, 16'sd13623, 16'sd9102,  16'sd3196,
          -16'sd3196, -16'sd9102, -16'sd13623, -16'sd16069 },

        // k = 2
        '{ 16'sd15137,  16'sd6270, -16'sd6270, -16'sd15137,
          -16'sd15137, -16'sd6270,  16'sd6270,  16'sd15137 },

        // k = 3
        '{ 16'sd13623, -16'sd3196, -16'sd16069, -16'sd9102,
           16'sd9102,  16'sd16069,  16'sd3196, -16'sd13623 },

        // k = 4
        '{ 16'sd11585, -16'sd11585, -16'sd11585, 16'sd11585,
           16'sd11585, -16'sd11585, -16'sd11585, 16'sd11585 },

        // k = 5
        '{ 16'sd9102,  -16'sd16069, 16'sd3196,  16'sd13623,
          -16'sd13623,-16'sd3196,  16'sd16069,-16'sd9102 },

        // k = 6
        '{ 16'sd6270,  -16'sd15137, 16'sd15137,-16'sd6270,
          -16'sd6270, 16'sd15137, -16'sd15137,16'sd6270 },

        // k = 7
        '{ 16'sd3196,  -16'sd9102,  16'sd13623,-16'sd16069,
           16'sd16069,-16'sd13623, 16'sd9102, -16'sd3196 }
    };

    integer k, n;

    always_comb begin
        // Pack scalar inputs into array
        x[0] = x0;
        x[1] = x1;
        x[2] = x2;
        x[3] = x3;
        x[4] = x4;
        x[5] = x5;
        x[6] = x6;
        x[7] = x7;

        // Clear accumulators
        for (k = 0; k < N; k++) begin
            acc[k] = '0;
        end

        // Matrix multiply: X = COS_LUT * x
        for (k = 0; k < N; k++) begin
            for (n = 0; n < N; n++) begin
                acc[k] += $signed(x[n]) * $signed(COS_LUT[k][n]);
            end
        end

        // Scale back from Q1.15 (arithmetic shift)
        for (k = 0; k < N; k++) begin
            X_int[k] = acc[k] >>> FRAC_BITS;
        end
    end

    // Assign to scalar outputs
    assign X0 = X_int[0];
    assign X1 = X_int[1];
    assign X2 = X_int[2];
    assign X3 = X_int[3];
    assign X4 = X_int[4];
    assign X5 = X_int[5];
    assign X6 = X_int[6];
    assign X7 = X_int[7];

endmodule
