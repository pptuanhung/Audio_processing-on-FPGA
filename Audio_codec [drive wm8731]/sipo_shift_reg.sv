module sipo_shift_reg
 #( parameter WD)
  (
    input  logic  clk_i,
    input  logic  rst_ni,
    input  logic  en_i,
    
    input  logic  wren_i, // shift
    
    input  logic            sdata_i,
    output logic  [WD-1:0]  pdata_o
    
  );
  
  logic  [WD:0]  data;
//  logic  [WD-1:0]  q_out;
  logic  en_sipo;
  
  
  assign en_sipo = en_i && wren_i;
  assign data[0] = sdata_i;
  
  genvar k, m;
  generate
    for ( k=0; k<WD; k++) begin:              GEN_PISO_REG
        d_ff  PISO_FF  ( .clk_i ( clk_i       ),
                         .rst_ni( rst_ni      ),
                         .prst_i( 1'b0        ),
                         .en_i  ( en_sipo     ),
                         .d_i   ( data[k]     ),
                         .q_o   ( data[k+1]     ));
    end
    
  endgenerate
  
  assign pdata_o = data[WD:1];
  
endmodule
