// ============================================================================
// dct8_controller.v
// --------------------------------------------------------------------------
// Simple generic controller skeleton for a 4-stage 8-point DCT pipeline.
//
// For now, this module isn't used by dct8_top (which wraps dct8_stream),
// but it gives you a clean starting point if you later want to build
// the full memory-based multi-stage architecture.
// ============================================================================

`include "dct8_params.vh"

module dct8_controller #(
    parameter N = DCT8_N
)(
    input  wire       clk,
    input  wire       rst_n,

    // Control interface
    input  wire       start,      // start a new 8-point DCT operation
    output reg        busy,       // 1 while controller is active
    output reg        done,       // 1 for one cycle when all stages/indices are done

    // Stage and index counters for driving address generator, etc.
    output reg [1:0]  stage,      // 0..3 for four stages
    output reg [2:0]  index       // 0..7 for the 8 sample positions
);

    // FSM states
    localparam ST_IDLE = 2'd0;
    localparam ST_RUN  = 2'd1;
    localparam ST_DONE = 2'd2;

    reg [1:0] state;
    reg [1:0] next_state;

    // Next-state logic
    always @(*) begin
        next_state = state;
        done       = 1'b0;

        case (state)
            ST_IDLE: begin
                if (start) begin
                    next_state = ST_RUN;
                end
            end

            ST_RUN: begin
                // When we've finished the last stage and last index,
                // go to DONE for one cycle.
                if ((stage == 2'd3) && (index == 3'd7)) begin
                    next_state = ST_DONE;
                end
            end

            ST_DONE: begin
                done       = 1'b1;
                next_state = ST_IDLE;
            end

            default: begin
                next_state = ST_IDLE;
            end
        endcase
    end

    // State, stage, index, busy registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_IDLE;
            stage <= 2'd0;
            index <= 3'd0;
            busy  <= 1'b0;
        end else begin
            state <= next_state;

            case (state)
                ST_IDLE: begin
                    busy  <= 1'b0;
                    stage <= 2'd0;
                    index <= 3'd0;
                    if (start) begin
                        busy <= 1'b1;
                    end
                end

                ST_RUN: begin
                    busy <= 1'b1;

                    // Iterate index 0..7, then advance stage 0..3
                    if (index == 3'd7) begin
                        index <= 3'd0;
                        if (stage != 2'd3)
                            stage <= stage + 2'd1;
                    end else begin
                        index <= index + 3'd1;
                    end
                end

                ST_DONE: begin
                    busy  <= 1'b0;
                    stage <= 2'd0;
                    index <= 3'd0;
                end
            endcase
        end
    end

endmodule
