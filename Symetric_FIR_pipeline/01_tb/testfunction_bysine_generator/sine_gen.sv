/*module sine_gen
  (
  input  logic clk_i, //clk50M
  input  logic rst_ni,
  
  output logic [15:0] wave_o
  );
  
  logic clk_f;
  logic [ 9:0] addr;
  logic [15:0] wave_t;
  
  
  scale_clock #(.FSC_WD(4)) SCALE_50M_FOR (
                      .clk_i  ( clk_i         ),
                      .rst_ni ( rst_ni        ),
                      .scale_i( 4'b1010        ), //10d
                      .clk_o  ( clk_f         ));
reg_count_up_vers2 #(.REG_WD(10)) BAND_SEL_COUNTER (
                                                          .clk_i   ( clk_f         ),
                                                          .rst_ni  ( rst_ni              ),
                                                          .reg_step( 10'd1             ),
                                                          .reg_max ( 10'd1023            ), 
                                                          .reg_o   ( addr         ));
 sine_lut ABC (
				.phase_addr(addr),
				.h(wave_t));
  
  assign wave_o = wave_t ;
  
endmodule */
module sine_gen
# ( parameter int GEN_WD ) // generating-data's width
  (
  input  logic clk_50,
  input  logic rst_ni,
  
  output logic [GEN_WD-1:0] wave_o
  );
  
  parameter int ADDR_WD = 10;

  
  reg [ADDR_WD-1:0] addr;
  reg [ GEN_WD-1:0] wave_temp;
  reg [ GEN_WD-1:0] wave_mem;
  logic clk_f;
  
  scale_clock #(.FSC_WD(4)) SCALE_50M_FOR (
                      .clk_i  ( clk_50         ),
                      .rst_ni ( rst_ni        ),
                      .scale_i( 4'b1010        ), //5d
                      .clk_o  ( clk_f         ));
  
  always_ff@(posedge clk_f, negedge rst_ni) begin: ADDR_COUNTER
    if ( ~rst_ni ) begin
                      addr      <= 'b0;
                      wave_temp <= 'b0;
                   end
    else           begin
                      addr      <= addr + 10'b1;
                      wave_temp <= wave_mem   ;
                   end
  end
    
  sine_lut ABC (
				.phase_addr(addr),
				.h(wave_mem));
assign wave_o = wave_temp;
endmodule