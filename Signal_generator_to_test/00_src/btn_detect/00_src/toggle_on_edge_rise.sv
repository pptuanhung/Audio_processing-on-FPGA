module toggle_on_edge_rise (
    input  wire clk_i,      // Clock input signal
    input  wire signal_i,   // Toggle output on rising edge of this signal
    input  wire rst_n,     // Active-low asynchronous reset
    output reg en_o        // Toggled output
);

  reg  toggle_state;  // Stores the current toggle state
  wire toggle_en;     // Signal indicating a rising edge detection
  
  // Detects rising edge of signal_i
  edge_rise_set_en count_key (
      .clk_i    ( clk_i    ),
      .signal_i ( signal_i ),
      .en_o     ( toggle_en )
  );

  // Toggle state on rising edge detection
  always @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) 
      toggle_state <= 1'b0; // Reset state
    else if (toggle_en)  
      toggle_state <= ~toggle_state;
  end

  assign en_o = toggle_state;
  
endmodule

