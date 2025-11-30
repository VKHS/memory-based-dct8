// ============================================================================
// dct8_block.v
// --------------------------------------------------------------------------
// Synchronous 8-point DCT block:
//  - Latches 8 inputs when start=1
//  - Computes DCT in one clock (using combinational kernel)
//  - Presents outputs with done=1 in the next cycle
// ============================================================================

module dct8_block #(
    parameter int N         = 8,
    parameter int IN_W      = 16,
    parameter int COEFF_W   = 16,
    parameter int OUT_W     = 16,
    parameter int FRAC_BITS = 15
)(
    input  logic                         clk,
    input  logic                         rst_n,

    input  logic                         start,
    input  logic signed [IN_W-1:0]       x0,
    input  logic signed [IN_W-1:0]       x1,
    input  logic signed [IN_W-1:0]       x2,
    input  logic signed [IN_W-1:0]       x3,
    input  logic signed [IN_W-1:0]       x4,
    input  logic signed [IN_W-1:0]       x5,
    input  logic signed [IN_W-1:0]       x6,
    input  logic signed [IN_W-1:0]       x7,

    output logic signed [OUT_W-1:0]      X0,
    output logic signed [OUT_W-1:0]      X1,
    output logic signed [OUT_W-1:0]      X2,
    output logic signed [OUT_W-1:0]      X3,
    output logic signed [OUT_W-1:0]      X4,
    output logic signed [OUT_W-1:0]      X5,
    output logic signed [OUT_W-1:0]      X6,
    output logic signed [OUT_W-1:0]      X7,
    output logic                         done
);

    // Registers to hold input samples
    logic signed [IN_W-1:0] x_reg[0:N-1];

    // Wires from combinational kernel
    logic signed [OUT_W-1:0] X0_w, X1_w, X2_w, X3_w;
    logic signed [OUT_W-1:0] X4_w, X5_w, X6_w, X7_w;

    // Instantiate combinational DCT kernel
    dct8_kernel_comb #(
        .N(N),
        .IN_W(IN_W),
        .COEFF_W(COEFF_W),
        .OUT_W(OUT_W),
        .FRAC_BITS(FRAC_BITS)
    ) u_kernel (
        .x0(x_reg[0]),
        .x1(x_reg[1]),
        .x2(x_reg[2]),
        .x3(x_reg[3]),
        .x4(x_reg[4]),
        .x5(x_reg[5]),
        .x6(x_reg[6]),
        .x7(x_reg[7]),

        .X0(X0_w),
        .X1(X1_w),
        .X2(X2_w),
        .X3(X3_w),
        .X4(X4_w),
        .X5(X5_w),
        .X6(X6_w),
        .X7(X7_w)
    );

    // Simple control: latch inputs on start, outputs available next cycle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_reg[0] <= '0;
            x_reg[1] <= '0;
            x_reg[2] <= '0;
            x_reg[3] <= '0;
            x_reg[4] <= '0;
            x_reg[5] <= '0;
            x_reg[6] <= '0;
            x_reg[7] <= '0;

            X0      <= '0;
            X1      <= '0;
            X2      <= '0;
            X3      <= '0;
            X4      <= '0;
            X5      <= '0;
            X6      <= '0;
            X7      <= '0;

            done    <= 1'b0;
        end else begin
            // Default: done low
            done <= 1'b0;

            if (start) begin
                // Latch inputs
                x_reg[0] <= x0;
                x_reg[1] <= x1;
                x_reg[2] <= x2;
                x_reg[3] <= x3;
                x_reg[4] <= x4;
                x_reg[5] <= x5;
                x_reg[6] <= x6;
                x_reg[7] <= x7;
            end

            // On every cycle, update outputs from combinational kernel
            X0 <= X0_w;
            X1 <= X1_w;
            X2 <= X2_w;
            X3 <= X3_w;
            X4 <= X4_w;
            X5 <= X5_w;
            X6 <= X6_w;
            X7 <= X7_w;

            // done goes high one cycle after start
            if (start)
                done <= 1'b1;
        end
    end

endmodule
