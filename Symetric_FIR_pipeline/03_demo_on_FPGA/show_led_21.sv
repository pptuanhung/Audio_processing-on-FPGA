module show_led_21 (
  input  logic  [2:0] sel,
  output logic  [6:0] hex_show [1:0]
);
  show_led_2 led_1 (
                            .sel(sel),
                            .out(hex_show[1]));
  show_led_1 led_0 (
                            .sel(sel),
                            .out(hex_show[0]));

endmodule