module set_and_show_demo_parameter
  (
          input logic CLOCK_50,
          input rst,
          input  logic  [1:0] KEY,
          output logic  [6:0] hex_show [5:0],
          output logic  [2:0] choose [2:0]
  );
  
       logic      en_reg_counter_1, en_reg_counter_0;
       logic      [1:0] sel_band;
       logic      [2:0] sel_gain [2:0];
       logic      [2:0] sel_gain_to_show;
       logic       [2:0]     en_band ;
//////////////////////////////////////////////////////////////////////////////////////////////
assign choose = sel_gain;
  
//////////////////////////////////////////////////////////////////////////////////////////////
  
  edge_detect          KEY_TO_CONFIG_1 (
                                           .clk_i     ( CLOCK_50           ),
                                           .edgerise_i( ~KEY[1]            ),
                                           .en_o      ( en_reg_counter_1   ));
  
  reg_count_up_vers2 #(.REG_WD(2)) BAND_SEL_COUNTER (
                                                          .clk_i   ( en_reg_counter_1 ),
                                                          .en_i    ( 1'b1             ),
                                                          .rst_ni  ( rst              ),
                                                          .reg_step( 2'b1             ),
                                                          .reg_max ( 2'b10            ), 
                                                          .reg_o   ( sel_band         ));

/////////////////////////////////////////////////////////////////////////////////////////////////////////

  edge_detect          KEY_TO_CONFIG_0 (
                                           .clk_i     ( CLOCK_50         ),
                                           .edgerise_i( ~KEY[0]          ),
                                           .en_o      ( en_reg_counter_0 ));

//////////////////////////////////////////////////////////////////////////////////////////////////////

  demux_3to1_1bit DEMUX_EN_BAND (
                                                          .sel_i( sel_band         ),
                                                          .en_i ( en_reg_counter_0 ),
                                                          .en_o ( en_band          ));
  
//////////////////////////////////////////////////////////////////////////////////////////////////////
  
  reg_count_up_vers2 #(.REG_WD(3)) GAIN_BAND_SEL_COUNTER_BASS (
                                                          .clk_i   ( en_band[0]      ),
                                                          .en_i    ( 1'b1            ),
                                                          .rst_ni  ( rst             ),
                                                          .reg_step( 3'b001          ),
                                                          .reg_max ( 3'b101          ),
                                                          .reg_o   ( sel_gain[0]     ));
  
  reg_count_up_vers2 #(.REG_WD(3)) GAIN_BAND_SEL_COUNTER_CENT (
                                                          .clk_i   ( en_band[1]     ),
                                                          .en_i    ( 1'b1           ),
                                                          .rst_ni  ( rst           ),
                                                          .reg_step( 3'b001          ),
                                                          .reg_max ( 3'b101         ), 
                                                          .reg_o   ( sel_gain[1]   ));
  
  reg_count_up_vers2 #(.REG_WD(3)) GAIN_BAND_SEL_COUNTER_TREB (
                                                          .clk_i   ( en_band[2]      ),
                                                          .en_i    ( 1'b1           ),
                                                          .rst_ni  ( rst           ),
                                                          .reg_step( 3'b001          ),
                                                          .reg_max ( 3'b101         ), 
                                                          .reg_o   ( sel_gain[2]   ));
  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  assign sel_gain_to_show = ( sel_band == 2'b00 ) ? sel_gain[0] :
                            ( sel_band == 2'b01 ) ? sel_gain[1] : 
					             ( sel_band == 2'b10)  ? sel_gain[2] : 3'b000;
  
  
  show_led  LED7 (
             .sel_gain( sel_gain_to_show ),
             .sel_band( sel_band ),
             .hex_show( hex_show ));
  
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module  demux_3to1_1bit
  (  
    input  logic  [1:0] sel_i,
    input  logic         en_i,

    output logic   [2:0] en_o  
  );
  
  assign en_o[0] = ~ sel_i[1] && ~ sel_i[0] && en_i;
  assign en_o[1] = ~ sel_i[1] &&   sel_i[0] && en_i;
  assign en_o[2] =   sel_i[1] && ~ sel_i[0] && en_i;
  
endmodule: demux_3to1_1bit