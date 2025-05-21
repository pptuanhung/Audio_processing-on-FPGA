module adder
(
	input logic  [24:0] a,
	input logic  [24:0] b,
	output logic [24:0] result
);

	assign result = a + b ;

endmodule
