module gain
  (
    input  logic  [ 2:0]    choose,
    input  logic  [23:0]    data_i,
    
    output logic  [23:0]    data_o
  );
  
  logic   [23:0] aud_gain_0_dB;
  logic   [23:0] aud_gain_6_dB;                   

  logic   [23:0] aud_gain_12_dB;
  
  logic   [23:0] aud_loss_6_dB;
  logic   [23:0] aud_loss_12_dB;
  
  assign  aud_gain_0_dB  = { data_i };
  assign  aud_gain_6_dB  = { data_i[22:0], 1'b0 };
  assign  aud_gain_12_dB = { data_i[21:0], 2'b0 };
  
  assign  aud_loss_6_dB  = { data_i[23], data_i[23:1] };
  assign  aud_loss_12_dB = { data_i[23], data_i[23], data_i[23:2] };
  
  assign  data_o =  ( choose == 3'h0 ) ? aud_gain_0_dB :
                   ( choose == 3'h1 ) ? aud_gain_6_dB  : 
                   ( choose == 3'h2 ) ? aud_gain_12_dB :
                   ( choose == 3'h3 ) ? aud_loss_12_dB :
                   ( choose == 3'h4 ) ? aud_loss_6_dB  : 24'b0;
  
endmodule