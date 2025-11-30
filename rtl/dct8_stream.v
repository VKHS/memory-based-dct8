// ============================================================================
// dct8_stream.v
// --------------------------------------------------------------------------
// Streaming 8-point DCT:
//  - Accepts 8 samples on din/din_valid
//  - Computes 8-point DCT
//  - Streams out 8 coefficients on dout/dout_valid
// ============================================================================

module dct8_stream #(
    parameter int N         = 8,
    parameter int IN_W      = 16,
    parameter int COEFF_W   = 16,
    parameter int OUT_W     = 16,
    parameter int FRAC_BITS = 15
)(
    input  logic                    clk,
    input  logic                    rst_n,

    // Input sample stream
    input  logic                    din_valid,
    input  logic signed [IN_W-1:0]  din,
    output logic                    din_ready,

    // Output coefficient stream
    output logic                    dout_valid,
    output logic signed [OUT_W-1:0] dout,
    input  logic                    dout_ready
);

    typedef enum logic [1:0] {
        S_IDLE,
        S_LOAD,
        S_COMPUTE,
        S_OUTPUT
    } state_t;

    state_t state, state_next;

    // Buffer for 8 input samples
    logic signed [IN_W-1:0] buf [0:N-1];
    logic [2:0]             in_idx;
    logic [2:0]             out_idx;

    // Wires to/from block DCT
    logic                   start_block;
    logic                   done_block;
    logic signed [OUT_W-1:0] X0, X1, X2, X3, X4, X5, X6, X7;

    // Instantiate block DCT
    dct8_block #(
        .N(N),
        .IN_W(IN_W),
        .COEFF_W(COEFF_W),
        .OUT_W(OUT_W),
        .FRAC_BITS(FRAC_BITS)
    ) u_block (
        .clk (clk),
        .rst_n (rst_n),
        .start (start_block),
        .x0 (buf[0]),
        .x1 (buf[1]),
        .x2 (buf[2]),
        .x3 (buf[3]),
        .x4 (buf[4]),
        .x5 (buf[5]),
        .x6 (buf[6]),
        .x7 (buf[7]),
        .X0 (X0),
        .X1 (X1),
        .X2 (X2),
        .X3 (X3),
        .X4 (X4),
        .X5 (X5),
        .X6 (X6),
        .X7 (X7),
        .done (done_block)
    );

    // FSM: next-state logic
    always_comb begin
        state_next  = state;
        din_ready   = 1'b0;
        start_block = 1'b0;
        dout_valid  = 1'b0;

        case (state)
            S_IDLE: begin
                din_ready  = 1'b1;
                if (din_valid) begin
                    state_next = S_LOAD;
                end
            end

            S_LOAD: begin
                din_ready = 1'b1;
                if (din_valid) begin
                    if (in_idx == 3'd7) begin
                        state_next  = S_COMPUTE;
                        start_block = 1'b1;
                    end
                end
            end

            S_COMPUTE: begin
                if (done_block) begin
                    state_next = S_OUTPUT;
                end
            end

            S_OUTPUT: begin
                if (dout_ready) begin
                    dout_valid = 1'b1;
                    if (out_idx == 3'd7) begin
                        state_next = S_IDLE;
                    end
                end
            end

            default: state_next = S_IDLE;
        endcase
    end

    // FSM: state registers and data path
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= S_IDLE;
            in_idx  <= 3'd0;
            out_idx <= 3'd0;
            buf[0]  <= '0;
            buf[1]  <= '0;
            buf[2]  <= '0;
            buf[3]  <= '0;
            buf[4]  <= '0;
            buf[5]  <= '0;
            buf[6]  <= '0;
            buf[7]  <= '0;
            dout    <= '0;
        end else begin
            state <= state_next;

            case (state)
                S_IDLE: begin
                    in_idx  <= 3'd0;
                    out_idx <= 3'd0;
                    if (din_valid & din_ready) begin
                        buf[0] <= din;
                        in_idx <= 3'd1;
                    end
                end

                S_LOAD: begin
                    if (din_valid & din_ready) begin
                        buf[in_idx] <= din;
                        in_idx      <= in_idx + 3'd1;
                    end
                end

                S_COMPUTE: begin
                    out_idx <= 3'd0;
                end

                S_OUTPUT: begin
                    if (dout_ready) begin
                        case (out_idx)
                            3'd0: dout <= X0;
                            3'd1: dout <= X1;
                            3'd2: dout <= X2;
                            3'd3: dout <= X3;
                            3'd4: dout <= X4;
                            3'd5: dout <= X5;
                            3'd6: dout <= X6;
                            3'd7: dout <= X7;
                            default: dout <= '0;
                        endcase
                        out_idx <= out_idx + 3'd1;
                    end
                end
            endcase
        end
    end

endmodule
