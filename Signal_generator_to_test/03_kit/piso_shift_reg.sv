module piso_shift_reg
 #( parameter WD)
  (
    input  logic  clk_i,
    input  logic  rst_ni,
    input  logic  en_i,
    
    input  logic  wren_i, // shift
    
    input  logic  [WD-1:0]  pdata_i,
    output logic            sdata_o
    
  );
  
  logic  [WD-1:0]  d_in;
  logic  [WD-1:0]  q_out;
  
  assign d_in[0] = pdata_i[0];
  
  genvar k, m;
  generate
    
    for ( m=1; m<WD; m++) begin:             GEN_FF_DQ
        assign  d_in[m] = ( ~wren_i ) ? pdata_i[m] : q_out[m-1];
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

////////////////////////////////////////////////////////////////////////
module d_ff
  (
    input  logic  clk_i,
    input  logic  rst_ni,
    input  logic  prst_i,
    input  logic  en_i,
    
    
    input  logic  d_i,
    output logic  q_o
   );
    
  always_ff@ (posedge clk_i, negedge rst_ni) begin: DFF
    if       (~rst_ni)       q_o <= 1'b0;
    else if  ( prst_i)       q_o <= 1'b1;
    else if  (   en_i)       q_o <= d_i;
    else                     q_o <= q_o;
  end
  
endmodule

    
    
    


