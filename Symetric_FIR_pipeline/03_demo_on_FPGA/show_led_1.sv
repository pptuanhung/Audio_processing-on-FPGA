module show_led_1 (
  input  logic  [2:0] sel,
  output logic  [6:0] out
);
  always@(*)  begin
    case(sel)
        3'b00: out <= 7'b0000010; //6
        3'b01: out <= 7'b0000010; //6
        3'b10: out <= 7'b0100100; //2
        3'b11: out <= 7'b0100100; //2
		       3'b100: out <= 7'b1000000; //0db
            default: out<= 7'b 1111111;

    endcase
  end
endmodule