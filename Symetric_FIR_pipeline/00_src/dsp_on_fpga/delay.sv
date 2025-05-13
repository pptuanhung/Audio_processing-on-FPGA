module group_delay
( input logic clk,
  input logic rst,
  input logic  [23:0] sam_in,
  output logic [23:0] sample [0:101]
  );
   
	assign sample [0] = sam_in;
  
  genvar i;
	generate
		for (i=0; i< 101; i++)
		begin: delay
		delay_ic dff (.clk (clk),
						.rst (rst), 
						.d (sample[i]), 
						.q (sample[i+1]));
		end
	endgenerate
endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

module delay_ic
    ( 
    input logic clk,
    input logic rst,
    input logic  [23 :0] d,
    output logic  [23 :0] q );
    
    always_ff@(posedge clk or negedge rst)
    begin
                if (!rst) begin
                        q <= 1'b0;
                        end
                        else
                        q <= d;
    end
endmodule
    
