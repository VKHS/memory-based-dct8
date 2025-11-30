// ============================================================================
// csa_4to2.v
// --------------------------------------------------------------------------
// 4:2 Carry-Save Adder (functional version).
// Takes four W-bit operands and produces sum and carry such that:
//   a + b + c + d = {carry, sum}
// (carry is the upper W bits, sum is the lower W bits).
// ============================================================================

module csa_4to2 #(
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    input  wire [WIDTH-1:0] c,
    input  wire [WIDTH-1:0] d,
    output wire [WIDTH-1:0] sum,
    output wire [WIDTH-1:0] carry
);

    wire [WIDTH:0] tmp;

    assign tmp   = a + b + c + d;
    assign sum   = tmp[WIDTH-1:0];
    assign carry = {tmp[WIDTH:1]};

endmodule
