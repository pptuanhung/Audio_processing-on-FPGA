module reg_count_up_vers2
#  ( parameter int REG_WD )
   (
    input  logic  clk_i,
    input  logic  en_i,
    input  logic  rst_ni,
    
    input  logic  [REG_WD-1:0]  reg_step,
    input  logic  [REG_WD-1:0]  reg_max,
    
    output logic  [REG_WD-1:0]  reg_o
   );
  
  logic              rstn_max;
  logic [REG_WD-1:0] reg_temp;
  logic [REG_WD-1:0] reg_stop;
  
  assign   reg_stop = reg_max + 'd1;
  assign   rstn_max = ( &reg_max ) ? rst_ni : ((|( reg_o ^ reg_stop )) && rst_ni);
  assign   reg_temp = reg_o + reg_step ;
  
  always_ff@( posedge clk_i, negedge rstn_max ) begin: REG_FF
    if      ( ~rstn_max )  reg_o <= 'b0;
    else if (   en_i    )  reg_o <= reg_temp;
  end
  
endmodule