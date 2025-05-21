module edge_rise_set_en (
    input  wire clk_i,
    input  wire signal_i,
    output reg en_o
);
  reg signal_prev;

  always @(posedge clk_i) begin
    en_o <= signal_i && !signal_prev;  // Detect rising edge of signal_i
    signal_prev <= signal_i;           // Store previous state
  end
  
endmodule

