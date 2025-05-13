module show_led_5 (
  input  logic  [1:0] sel,
  output logic  [6:0] out
);
  always@(*)  begin
    case(sel)
        2'b00: out <= 7'b0001000; //A 
        2'b01: out <= 7'b0000110; //E
        2'b10: out <= 7'b1001111; //I
        2'b11: out <= 7'b1111111; //no

    endcase
  end
endmodule