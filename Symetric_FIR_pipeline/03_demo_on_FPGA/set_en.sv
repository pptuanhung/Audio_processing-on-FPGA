module set_en (
    input  logic clk_i,
    input  logic edgerise_i,
    output logic en_o
);

  logic  en_for_ever = 0;
  logic  en_for_clk;
  
  edge_detect  KEY_TO_COUNT  (
                            .clk_i     ( clk_i        ),
                            .edgerise_i( edgerise_i   ),
                            .en_o      ( en_for_clk   ));
  
  always_ff@( posedge clk_i) begin
    if ( en_for_clk )  en_for_ever <= ~en_for_ever;
  end
  
  assign en_o = en_for_ever;
  
endmodule