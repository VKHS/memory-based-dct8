// ============================================================================
// cla_adder.v
// --------------------------------------------------------------------------
// Parameterized adder with carry-in and carry-out.
// Named "cla_adder" but implemented using the '+' operator;
// synthesizer will map to appropriate adder structure.
// ============================================================================

module cla_adder #(
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire             cin,
    output wire [WIDTH-1:0] sum,
    output wire             cout
);

    assign {cout, sum} = a + b + cin;

endmodule
