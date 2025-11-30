// ============================================================================
// tb_dct8_top.v
// --------------------------------------------------------------------------
// Testbench for dct8_top (streaming 8-point DCT).
//  - Feeds a few 8-sample blocks
//  - Prints the 8 output coefficients for each block
// ============================================================================

`timescale 1ns/1ps

`include "dct8_params.vh"

module tb_dct8_top;

    localparam IN_W  = DCT8_IN_W;
    localparam OUT_W = DCT8_OUT_W;

    reg                     clk;
    reg                     rst_n;

    reg                     din_valid;
    reg  signed [IN_W-1:0]  din;
    wire                    din_ready;

    wire                    dout_valid;
    wire signed [OUT_W-1:0] dout;
    reg                     dout_ready;

    // Instantiate top-level DUT
    dct8_top dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .din_valid  (din_valid),
        .din        (din),
        .din_ready  (din_ready),
        .dout_valid (dout_valid),
        .dout       (dout),
        .dout_ready (dout_ready)
    );

    // Clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        rst_n      = 1'b0;
        din_valid  = 1'b0;
        din        = 0;
        dout_ready = 1'b1;
        #50;
        rst_n = 1'b1;
    end

    // Tasks to send and receive one block
    task send_block;
        input signed [IN_W-1:0] vec [0:7];
        integer i;
        begin
            for (i = 0; i < 8; i = i + 1) begin
                @(posedge clk);
                while (!din_ready) @(posedge clk);
                din       <= vec[i];
                din_valid <= 1'b1;
            end
            @(posedge clk);
            din_valid <= 1'b0;
        end
    endtask

    // Simple monitor for outputs
    integer coeff_count;
    initial coeff_count = 0;

    always @(posedge clk) begin
        if (dout_valid && dout_ready) begin
            $display("DOUT[%0d] = %0d", coeff_count, dout);
            coeff_count = coeff_count + 1;
            if (coeff_count == 8) begin
                $display("---- End of 8-point DCT block ----");
                coeff_count = 0;
            end
        end
    end

    // Stimulus
    initial begin
        signed [IN_W-1:0] blk0 [0:7];
        signed [IN_W-1:0] blk1 [0:7];
        integer i;

        // Wait for reset
        @(posedge rst_n);
        @(posedge clk);

        // Block 0: ramp
        blk0[0] = 0;
        blk0[1] = 10;
        blk0[2] = 20;
        blk0[3] = 30;
        blk0[4] = 40;
        blk0[5] = 50;
        blk0[6] = 60;
        blk0[7] = 70;

        // Block 1: simple pattern
        blk1[0] = 100;
        blk1[1] = 50;
        blk1[2] = 0;
        blk1[3] = -50;
        blk1[4] = -100;
        blk1[5] = -50;
        blk1[6] = 0;
        blk1[7] = 50;

        $display("Sending block 0...");
        send_block(blk0);

        // Wait some cycles
        repeat (20) @(posedge clk);

        $display("Sending block 1...");
        send_block(blk1);

        // Wait for outputs to flush
        repeat (40) @(posedge clk);

        $display("Simulation finished.");
        $finish;
    end

endmodule
