module scale_clock 
#  ( parameter int FSC_WD ) // freq-scale WD
   (
    input  logic  clk_i, rst_ni,
    input  logic  [FSC_WD-1:0] scale_i,
    output logic  clk_o
   );

  logic [FSC_WD-1:0] scale_t = 'b0;
  logic [FSC_WD-1:0] scale_t_fix  ;

  logic clk_t = 1'b0;
  logic count_up;
  
  assign scale_t_fix = scale_i ;//- 1;
  assign count_up = ~|( scale_t ^ scale_t_fix );
  
  always_ff@ (posedge clk_i, negedge rst_ni) begin: SCALE_COUNTER
    if      ( ~rst_ni  )  begin
                               clk_t   <= 1'b0;
                               scale_t <=  'b0;
                          end
    else if ( count_up )  begin
                               clk_t   <= ~clk_t;
                               scale_t <=    'b0;
                          end
    else                  begin
                               clk_t   <= clk_t;
                               scale_t <= scale_t + 2;
                          end
  end
  
  assign clk_o = clk_t;

endmodule
