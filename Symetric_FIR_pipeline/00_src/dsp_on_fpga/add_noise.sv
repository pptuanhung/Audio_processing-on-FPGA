module add_noise
(
	input logic  [23:0] a,
	input logic  [23:0] b,
	output logic [23:0] result
);

	assign result = a + b ;

endmodule
