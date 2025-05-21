module demo
 (
  input               CLOCK_50,
  input      [3:0]    KEY,
  input      [9:0]    SW,
  output     [9:0]    LEDR,
  output     [6:0]    HEX0,
  output     [6:0]    HEX1,
  output     [6:0]    HEX2,
  output     [6:0]    HEX3,
  output     [6:0]    HEX4,
  output     [6:0]    HEX5,
  input               AUD_ADCDAT,
  output              AUD_ADCLRCK,
  output              AUD_BCLK,
  output              AUD_DACDAT,
  output              AUD_DACLRCK,
  output              AUD_XCK,
  output              FPGA_I2C_SCLK,
  inout               FPGA_I2C_SDAT
 );
  
  logic clk_12mhz;   //   12M_HZ
  logic clk_i2c;     // ~400K_HZ
  logic clk_sample;  //   48K_HZ
  logic clk_wave;
  
  logic  rst_ni;
  logic  en_i;
  logic  en_sys, en_sys_delay_for_config;
  logic  en_reg_counter, en_sel_counter, mode_sel;
  logic  start_config, done_config;
  logic  load_dac_dat;
  logic  en_band_sel;
  
  logic            [2:0]  inf_sel;
  logic            [2:0] wave_sel;
  logic           [13:0]    f_sel;
  logic            [1:0]    d_sel;
  logic  [24-GEN_WD-1:0]    g_sel;
  logic  [24-  N_WD-1:0]  gns_sel;
  logic            [7:0]  fns_sel;
  logic                    ns_inject;
  
  logic            [6:0] show_hex_mode_1 [5:0];
  logic            [6:0] show_hex_mode_2 [5:0];
  logic            [6:0] show_hex        [5:0];

  
  logic            [2:0] bands_gain_sel [9:0];
  
  logic           [23:0] sample_from_linein;
  logic           [23:0] sample_from_linein_mux;
  
  logic           [23:0] data_from_genwav;
  logic           [23:0] data_from_genwav_mux;
  
  logic           [23:0] data_to_equalizer;
  logic           [23:0] data_from_equalizer;
  
  logic           [23:0] data_to_lineout;
  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  gen12Mhz_0002    PLL_12MHZ  (
                .refclk  ( CLOCK_50  ),
                .rst     ( 1'b0      ),
                .outclk_0( clk_12mhz ));
  
  forever_set_en_when_edge_rise   KEY_TO_ENABLE (
                                     .clk_i     ( clk_i2c      ),
                                     .edgerise_i( ~KEY[3]      ),
                                     .en_o      ( en_sys       ));
 set_en_when_edge_rise           KEY_TO_CONFIG_2 (
                                     .clk_i     ( clk_i2c                 ),
                                     .edgerise_i( en_sys                  ),
                                     .en_o      ( start_config            ));
												 assign  rst_ni =  KEY[3] | ~SW[0];
  assign  en_i   = en_sys;
  
  setup_codec  CODEC_SETUP  (
                            .clk_50mhz ( CLOCK_50      ),
                            .rst_ni    ( rst_ni        ),
                            .en_i      ( en_i          ),
                            .start_cf_i( start_config  ),
                            .i2c_sdin_o( FPGA_I2C_SDAT ),
                            .i2c_sclk_o( FPGA_I2C_SCLK ),
                            .cf_done_o ( done_config   ),
                            .clk_i2c_o ( clk_i2c       ));
  
  set_en_when_edge_rise           KEY_TO_EN_PARA_COUNTER       (
                                           .clk_i     ( CLOCK_50         ),
                                           .edgerise_i( ~KEY[0]          ),
                                           .en_o      ( en_reg_counter   ));
  
  set_en_when_edge_rise           KEY_TO_EN_PARA_SEL      (
                                           .clk_i     ( CLOCK_50         ),
                                           .edgerise_i( ~KEY[1]          ),
                                           .en_o      ( en_sel_counter   ));
  
  forever_set_en_when_edge_rise   KEY_TO_SEL_MODE     (
                                           .clk_i     ( CLOCK_50         ),
                                           .edgerise_i( ~KEY[2]          ),
                                           .en_o      ( mode_sel         ));
  
  assign  en_band_select_mode2 = ( mode_sel ) ? en_sel_counter : 1'b0 ;
  assign  en_band_countt_mode2 = ( mode_sel ) ? en_reg_counter : 1'b0 ;
  
  assign  en_inf_select_mode1  = ( mode_sel ) ? 1'b0 : en_sel_counter ;
  assign  en_inf_countt_mode1  = ( mode_sel ) ? 1'b0 : en_reg_counter ;
  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  set_and_show_led7_for_gen_wave_parameter                     DEMO_VERS_1  (
                                                                  .clk_i               ( CLOCK_50             ),
                                                                  .rst_ni              ( rst_ni               ),
                                                                  .en_counter_i        ( en_inf_countt_mode1  ),
                                                                  .en_inf_sel_i        ( en_inf_select_mode1  ),
                                                                  .step_param_counter_i( SW[7:0]              ),
                                                                  .f_sel_o             ( f_sel                ),
                                                                  .d_sel_o             ( d_sel                ),
                                                                  .g_sel_o             ( g_sel                ),
                                                                  .wave_sel_o          ( wave_sel             ),
                                                                  .fns_sel_o           ( fns_sel              ),
                                                                  .gns_sel_o           ( gns_sel              ),
                                                                  .hex_show_o          ( show_hex_mode_1      ));
  
  set_and_show_led7_for_audio_equalizer_parameter              DEMO_VERS_2  (
                                                                  .clk_i               ( CLOCK_50             ),
                                                                  .rst_ni              ( rst_ni               ),
                                                                  .en_i                ( en_i                 ),
                                                                  .en_band_sel_i       ( en_band_select_mode2 ),
                                                                  .en_para_i           ( en_band_countt_mode2 ),
                                                                  .gsel_o              ( bands_gain_sel       ),
                                                                  .hex_show_o          ( show_hex_mode_2      ));
  
  genvar m;
  generate 
    for ( m = 0 ; m < 6 ; m++ ) begin: DEMO_SHOW_HEX
       assign show_hex[m] = ( mode_sel ) ? show_hex_mode_2[m] : show_hex_mode_1[m];
    end
  endgenerate
  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  core_wave_generator_vers_2    GEN_WAVE_CORE  (
                               .clk50M_i   ( CLOCK_50         ),
                               .rst_ni     ( rst_ni           ),
                               .en_i       ( en_i             ),
                               .duty_i     ( d_sel            ),
                               .fsel_i     ( f_sel            ),
                               .gsel_i     ( g_sel            ),
                               .wave_sel_i ( wave_sel         ),
                               .fns_sel_i  ( fns_sel          ),
                               .gns_sel_i  ( gns_sel          ),
                               .dig_wav_o  ( data_from_genwav ));
  
  assign  sample_from_linein_mux  = ( SW[8] ) ? sample_from_linein : 24'd0 ;
  assign    data_from_genwav_mux  = ( SW[9] ) ?   data_from_genwav : 24'd0 ;
  assign    data_to_equalizer     = sample_from_linein_mux + data_from_genwav_mux;
  
  core_audio_equalizer     AUD_EQUALIZER  (
                               .clk_i   ( CLOCK_50    ),
                               .rst_ni  ( rst_ni      ),
                               .en_i    ( en_i        ),
                               .gsel_i  ( bands_gain_sel      ),
                               .aud_i   ( data_to_equalizer   ),
                               .aud_o   ( data_from_equalizer ));
  
  assign data_to_lineout = ( mode_sel ) ? data_from_equalizer : data_to_equalizer ;
  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  forever_set_en_when_edge_rise  DONE_CF  (
                               .clk_i     ( CLOCK_50         ),
                               .edgerise_i( done_config      ),
                               .en_o      ( load_dac_dat     ));
  
  codec_digital_audio_interface  FPGA_CODEC_BUFFER  (
                               .clk_i               ( clk_12mhz     ),
                               .rst_ni              ( rst_ni        ),
                               .en_i                ( en_i          ),
                               .load_i              ( load_dac_dat  ),
                               .data_to_lineout_i   ( data_to_lineout    ),
                               .sample_from_linein_o( sample_from_linein ),
                               .codec_aud_adc_dat_i ( AUD_ADCDAT         ),
                               .codec_aud_dac_dat_o ( AUD_DACDAT         ),
                               .codec_bclk_o        ( AUD_BCLK           ),
                               .codec_xck_o         ( AUD_XCK            ),
                               .codec_adc_lrck_o    ( AUD_ADCLRCK        ),
                               .codec_dac_lrck_o    ( AUD_DACLRCK        ));
  
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  assign  LEDR[9] = load_dac_dat;
  assign  LEDR[8] = en_sys;
  
  assign HEX0 = show_hex[0];
  assign HEX1 = show_hex[1];
  assign HEX2 = show_hex[2];
  assign HEX3 = show_hex[3];
  assign HEX4 = show_hex[4];
  assign HEX5 = show_hex[5];
  
  assign LEDR[7:0] = SW[7:0];
  
endmodule