module treble (
input logic clk,
    input logic rst,
    input logic [23 :0] sam_in,
    input logic [2:0] choose,
    output logic  [23 :0] data_out);

// wire
logic [23:0] data;

//fir 
tre_fir treb (.clk(clk),
				.rst(rst),
				.sam_in(sam_in),
				.data_out(data));
// gain
gain  gaintreb    (.data_i(data),
				     .data_o(data_out),
				     .choose(choose) );
endmodule