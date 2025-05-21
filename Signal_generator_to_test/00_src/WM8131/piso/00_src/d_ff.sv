module d_ff
  (
    input  logic  clk_i,
    input  logic  rst_ni,
    input  logic  prst_i,
    input  logic  en_i,
    
    
    input  logic  d_i,
    output logic  q_o
   );
    
  always_ff@ (posedge clk_i, negedge rst_ni) begin: DFF
    if       (~rst_ni)       q_o <= 1'b0;
    else if  ( prst_i)       q_o <= 1'b1;
    else if  (   en_i)       q_o <= d_i;
    else                     q_o <= q_o;
  end
  
endmodule
