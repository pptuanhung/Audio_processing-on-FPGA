module mid (
input logic clk,
    input logic rst,
    input logic  signed [23 :0] sam_in,
    input logic [2:0]choose,
    output logic signed  [23 :0] data_out);

// wire
logic [23:0] data;

//fir 
mid_fir mid (.clk(clk),
				.rst(rst),
				.sam_in(sam_in),
				.data_out(data));
// gain
gain  gainmid    (.data_i(data),
				     .data_o(data_out),
				     .choose(choose) );
endmodule