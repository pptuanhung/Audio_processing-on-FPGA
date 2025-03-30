module adder #(
    parameter WIDTH = 40
)(
    input  logic signed [WIDTH-1:0] a,
    input  logic signed [WIDTH-1:0] b,
    output logic signed [WIDTH:0]   sum // extra bit for overflow
);
    assign sum = a + b;
endmodule
