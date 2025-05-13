module show_led (
  input  logic  [2:0] sel_gain,
  input logic [1:0] sel_band,
  output logic  [6:0] hex_show [5:0]
);
  show_led_6 led_6 (
                            .sel_band(sel_band),
                            .out(hex_show[5]));
  show_led_5 led_5 (
                            .sel_band(sel_band),
                            .out(hex_show[4]));
  show_led_4 led_4 (
                            .sel_band(sel_band),
                            .out(hex_show[3]));
  show_led_3 led_3 (
                            .sel_band(sel_band),
                            .out(hex_show[2]));
 show_led_2 led_1 (
                            .sel_gain(sel_gain),
                            .out(hex_show[1]));
  show_led_1 led_0 (
                            .sel_gain(sel_gain),
                            .out(hex_show[0]));

endmodule: show_led
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module show_led_1 (
  input  logic  [2:0] sel_gain,
  output logic  [6:0] out
);

/* always_comb  begin  
  
    case(sel_gain)
        3'b000: out = 7'b1000000; //0db
        3'b001: out = 7'b0000010; //6 
        3'b010: out = 7'b0100100; //2
        3'b011: out = 7'b0100100; //2
        3'b100: out = 7'b0000010; //6
        3'b101: out= 7'b1111111;
        default: out= 7'b1111111;
		      endcase
  end
*/
assign out = (sel_gain == 3'b000)?  7'b1000000 :
             (sel_gain == 3'b001)? 7'b0000010 :
             (sel_gain == 3'b010)? 7'b0100100 :
             (sel_gain == 3'b011)? 7'b0100100 :
             (sel_gain == 3'b100)? 7'b0000010 : 7'b1111111;

endmodule:show_led_1
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module show_led_2 (
  input  logic  [2:0] sel_gain,
  output logic  [6:0] out
);

/*  always_comb  begin
  
    case(sel_gain)
        3'b000: out = 7'b1000000; //0db
        3'b001: out = 7'b1111111; //no (6)
        3'b010: out = 7'b1111001; //1  (12)
        3'b011: out = 7'b0111001; //-1(-12)
        3'b100: out = 7'b0111111; //- (-6)
        3'b101: out= 7'b1111111 ;
        default: out= 7'b1111111;
		  endcase
		  end
*/
assign out = (sel_gain == 3'b000) ? 7'b1000000 :
             (sel_gain == 3'b001)?  7'b1111111 :
             (sel_gain == 3'b010)? 7'b1111001 :
             (sel_gain == 3'b011)? 7'b0111001 :
             (sel_gain == 3'b100)? 7'b0111111 : 7'b1111111;
endmodule: show_led_2
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module show_led_3 (
  input  logic  [1:0] sel_band,
  output logic  [6:0] out
);
  always@(*)  begin
    case(sel_band)
        2'b00: out = 7'b0010010; //S 
        2'b01: out = 7'b1111111; //no
        2'b10: out = 7'b0001001; //H
        2'b11: out = 7'b1111111; //no
     default:    out = 7'b1111111;
    endcase
  end
endmodule: show_led_3
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module show_led_4 (
  input  logic  [1:0] sel_band,
  output logic  [6:0] out
);
  always@(*)  begin
    case(sel_band)
        2'b00: out = 7'b0010010; //S 
        2'b01: out = 7'b1001000; //n
        2'b10: out = 7'b1000010; //G
        2'b11: out = 7'b1111111; //no
    default:    out = 7'b1111111;
    endcase
  end
endmodule: show_led_4
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module show_led_5 (
  input  logic  [1:0] sel_band,
  output logic  [6:0] out
);
  always@(*)  begin
    case(sel_band)
        2'b00: out = 7'b0001000; //A 
        2'b01: out = 7'b0000110; //E
        2'b10: out = 7'b1001111; //I
        2'b11: out = 7'b1111111; //no
     default:   out = 7'b1111111;
    endcase
  end
endmodule: show_led_5
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module show_led_6 (
  input  logic  [1:0] sel_band,
  output logic  [6:0] out
);
  always@(*)  begin
    case(sel_band)
        2'b00: out = 7'b0000000; //B
        2'b01: out = 7'b1000110; //C
        2'b10: out = 7'b0001001; //H
        2'b11: out = 7'b1111111; //no
      default: out = 7'b1111111;
    endcase
  end
endmodule: show_led_6
