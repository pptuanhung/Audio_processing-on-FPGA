module set_en_when_edge_rise (
    input  logic clk_i,
    input  logic edgerise_i,
    output logic en_o
);
  logic  edgerise_temp, edgerise_temp_delay;
  assign edgerise_temp = edgerise_i;
  
  always_ff@( posedge clk_i) begin
    if ( edgerise_temp && !edgerise_temp_delay )  en_o <= 1'b1;
    else                                          en_o <= 1'b0;
    edgerise_temp_delay <= edgerise_temp;
  end
  
endmodule