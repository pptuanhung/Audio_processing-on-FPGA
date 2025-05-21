module show_led_6 (
  input  logic  [1:0] sel,
  output logic  [6:0] out
);
  always@(*)  begin
    case(sel)
        2'b00: out <= 7'b0000000; //B
        2'b01: out <= 7'b1000110; //C
        2'b10: out <= 7'b0001001; //H
        2'b11: out <= 7'b1111111; //no

    endcase
  end
endmodule