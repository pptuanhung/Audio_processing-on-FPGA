module show_led_2 (
  input  logic  [2:0] sel,
  output logic  [6:0] out
);

  always_comb  begin
    case(sel)
        3'b000: out <= 7'b1111111; //no (6)
        3'b001: out <= 7'b1000000; //- (-6)
        3'b010: out <= 7'b1111001; //1  (12)
        3'b011: out <= 7'b0111001; //-1(-12)
              3'b100: out <= 7'b1000000; //0db
            default: out<= 7'b 1111111;

    endcase
  end
endmodule