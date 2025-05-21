module piso_shift_reg
 #( parameter WD = 8) 
  (
    input  logic  clk_i,
    input  logic  rst_ni,
    input  logic  en_i,
    
    input  logic  shift_en, // shift_en =1 take data shift, shift_en =0 take data from input pdata_i
    
    input  logic  [WD-1:0]  pdata_i,
    output logic            sdata_o
    
  );
  
  logic  [WD-1:0]  d_in; //Lsb always stable
  logic  [WD-1:0]  q_out;
  
  assign d_in[0] = pdata_i[0];
  
  genvar k, m;
  generate
    
    for ( m=1; m<WD; m++) begin:             GEN_FF_DQ
        assign  d_in[m] = ( shift_en ) ?  q_out[m-1] : pdata_i[m];
    end
    
    for ( k=0; k<WD; k++) begin:              GEN_PISO_REG
        d_ff  PISO_FF  ( .clk_i ( clk_i    ),
                         .rst_ni( rst_ni   ),
                         .prst_i( 1'b0     ),
                         .en_i  ( en_i     ),
                         .d_i   (  d_in[k] ),
                         .q_o   ( q_out[k] ));
    end
    
  endgenerate
  
  assign sdata_o = q_out[WD-1];
  
endmodule

    
    
    



