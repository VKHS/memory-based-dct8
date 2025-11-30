// ============================================================================
// tb_dct8_block.v
// --------------------------------------------------------------------------
// Testbench for dct8_block (8-point DCT block).
//  - Generates random 8-sample vectors
//  - Computes golden DCT in real (double) using DCT-II formula
//  - Compares hardware outputs against golden (with small tolerance)
// ============================================================================

`timescale 1ns/1ps

`include "dct8_params.vh"

module tb_dct8_block;

    // Parameters (reuse from header)
    localparam N         = DCT8_N;
    localparam IN_W      = DCT8_IN_W;
    localparam OUT_W     = DCT8_OUT_W;
    localparam COEFF_W   = DCT8_COEFF_W;
    localparam FRAC_BITS = DCT8_FRAC_BITS;

    // DUT ports
    reg                     clk;
    reg                     rst_n;

    reg                     start;
    reg  signed [IN_W-1:0]  x0, x1, x2, x3, x4, x5, x6, x7;
    wire signed [OUT_W-1:0] X0, X1, X2, X3, X4, X5, X6, X7;
    wire                    done;

    // Instantiate DUT
    dct8_block #(
        .N        (N),
        .IN_W     (IN_W),
        .COEFF_W  (COEFF_W),
        .OUT_W    (OUT_W),
        .FRAC_BITS(FRAC_BITS)
    ) dut (
        .clk (clk),
        .rst_n (rst_n),
        .start (start),
        .x0 (x0),
        .x1 (x1),
        .x2 (x2),
        .x3 (x3),
        .x4 (x4),
        .x5 (x5),
        .x6 (x6),
        .x7 (x7),
        .X0 (X0),
        .X1 (X1),
        .X2 (X2),
        .X3 (X3),
        .X4 (X4),
        .X5 (X5),
        .X6 (X6),
        .X7 (X7),
        .done (done)
    );

    // Clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // 100 MHz
    end

    // Golden reference arrays
    real x_real [0:7];
    real X_ref [0:7];

    integer i, k, n;

    // DCT-II reference function (1D, length 8)
    task dct8_ref;
        begin
            for (k = 0; k < 8; k = k + 1) begin
                real alpha;
                real sum;
                alpha = (k == 0) ? $sqrt(1.0 / 8.0) : $sqrt(2.0 / 8.0);
                sum   = 0.0;
                for (n = 0; n < 8; n = n + 1) begin
                    real angle;
                    angle = (3.141592653589793 / 16.0) * (2.0 * n + 1.0) * k;
                    sum   = sum + x_real[n] * $cos(angle);
                end
                X_ref[k] = alpha * sum;
            end
        end
    endtask

    // Reset
    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        x0 = 0; x1 = 0; x2 = 0; x3 = 0;
        x4 = 0; x5 = 0; x6 = 0; x7 = 0;
        #50;
        rst_n = 1'b1;
    end

    // Main stimulus
    initial begin
        integer test;
        integer errors;
        integer total_errors;
        real    tol;

        total_errors = 0;
        tol = 1.5; // tolerance in LSBs

        // Wait for reset
        @(posedge rst_n);
        @(posedge clk);

        for (test = 0; test < 20; test = test + 1) begin
            // Generate random input samples in some range
            x0 = $random % 128;
            x1 = $random % 128;
            x2 = $random % 128;
            x3 = $random % 128;
            x4 = $random % 128;
            x5 = $random % 128;
            x6 = $random % 128;
            x7 = $random % 128;

            // Copy to real array
            x_real[0] = x0;
            x_real[1] = x1;
            x_real[2] = x2;
            x_real[3] = x3;
            x_real[4] = x4;
            x_real[5] = x5;
            x_real[6] = x6;
            x_real[7] = x7;

            // Compute golden DCT
            dct8_ref();

            // Kick the DUT
            @(posedge clk);
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;

            // Wait one cycle for done (dct8_block asserts done on the start cycle)
            @(posedge clk);

            // Compare
            errors = 0;

            // Cast golden to integer with rounding
            integer Xgold [0:7];
            Xgold[0] = $rtoi(X_ref[0] + (X_ref[0] >= 0 ? 0.5 : -0.5));
            Xgold[1] = $rtoi(X_ref[1] + (X_ref[1] >= 0 ? 0.5 : -0.5));
            Xgold[2] = $rtoi(X_ref[2] + (X_ref[2] >= 0 ? 0.5 : -0.5));
            Xgold[3] = $rtoi(X_ref[3] + (X_ref[3] >= 0 ? 0.5 : -0.5));
            Xgold[4] = $rtoi(X_ref[4] + (X_ref[4] >= 0 ? 0.5 : -0.5));
            Xgold[5] = $rtoi(X_ref[5] + (X_ref[5] >= 0 ? 0.5 : -0.5));
            Xgold[6] = $rtoi(X_ref[6] + (X_ref[6] >= 0 ? 0.5 : -0.5));
            Xgold[7] = $rtoi(X_ref[7] + (X_ref[7] >= 0 ? 0.5 : -0.5));

            real diff;
            diff = X0 - Xgold[0]; if ((diff > tol) || (diff < -tol)) errors = errors + 1;
            diff = X1 - Xgold[1]; if ((diff > tol) || (diff < -tol)) errors = errors + 1;
            diff = X2 - Xgold[2]; if ((diff > tol) || (diff < -tol)) errors = errors + 1;
            diff = X3 - Xgold[3]; if ((diff > tol) || (diff < -tol)) errors = errors + 1;
            diff = X4 - Xgold[4]; if ((diff > tol) || (diff < -tol)) errors = errors + 1;
            diff = X5 - Xgold[5]; if ((diff > tol) || (diff < -tol)) errors = errors + 1;
            diff = X6 - Xgold[6]; if ((diff > tol) || (diff < -tol)) errors = errors + 1;
            diff = X7 - Xgold[7]; if ((diff > tol) || (diff < -tol)) errors = errors + 1;

            if (errors == 0) begin
                $display("TEST %0d: PASS", test);
            end else begin
                $display("TEST %0d: FAIL (%0d coefficient errors)", test, errors);
                $display("  Inputs: %0d %0d %0d %0d %0d %0d %0d %0d",
                    x0,x1,x2,x3,x4,x5,x6,x7);
                $display("  HW: %0d %0d %0d %0d %0d %0d %0d %0d",
                    X0,X1,X2,X3,X4,X5,X6,X7);
                $display("  REF: %0d %0d %0d %0d %0d %0d %0d %0d",
                    Xgold[0],Xgold[1],Xgold[2],Xgold[3],
                    Xgold[4],Xgold[5],Xgold[6],Xgold[7]);
                total_errors = total_errors + 1;
            end

            @(posedge clk);
        end

        $display("=================================================");
        if (total_errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TOTAL FAILURES: %0d", total_errors);
        $display("=================================================");

        $finish;
    end

endmodule
