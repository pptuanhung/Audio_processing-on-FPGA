module sine_gen
# ( parameter int GEN_WD ) // generating-data's width
  (
  input  logic clk_i,
  input  logic rst_ni,
  
  output logic [GEN_WD-1:0] wave_o
  );
  
  parameter int ADDR_WD = 8;
  
  reg [ADDR_WD-1:0] addr;
  reg [ GEN_WD-1:0] wave_temp;
  reg [ GEN_WD-1:0] wave_mem;
  
  always_ff@(posedge clk_i, negedge rst_ni) begin: ADDR_COUNTER
    if ( ~rst_ni ) begin
                      addr      <= 'b0;
                      wave_temp <= 'b0;
                   end
    else           begin
                      addr      <= addr + 1'b1;
                      wave_temp <= wave_mem   ;
                   end
  end
    
  sine_mem # ( .ADDR_WD(ADDR_WD), .WD(GEN_WD)) SINE_DATA (
                   .addr_i( addr ),
                   .data_o( wave_mem ));
  
  assign wave_o = wave_temp;
  
endmodule