module demo_audio
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
  //////////////////////////////////////////////////////
  
  logic            [6:0] show_hex        [5:0];  
  logic            rst_ni;
  logic            clk_sample;
  logic clk_12mhz;   //   12M_HZ
  logic clk_i2c;     // ~400K_HZ
  
  logic  en_sys;
  logic  en_i;
  logic  start_config, done_config;
  logic  load_dac_dat;
  
  logic           [23:0] data_no_eq;
  logic           [23:0] data_eq;
  
  logic           [2:0] choose [2:0];
  logic            mode_sel;
  
  logic           [23:0] sample_from_linein;
  logic            [23:0] data_to_lineout;
  /////////////////////////////////////////////////////
  assign data_no_eq = sample_from_linein;
  /////////////////////////////////////////////////////
   assign  rst_ni =  KEY[3] | ~SW[0];
   assign  mode_sel = SW[2];
  
  assign HEX0 = show_hex[0];
  assign HEX1 = show_hex[1];
  assign HEX2 = show_hex[2];
  assign HEX3 = show_hex[3];
  assign HEX4 = show_hex[4];
  assign HEX5 = show_hex[5];
  
  assign LEDR[7:0] = SW[7:0];
 //////////////////////////////////////////////////////
 pll_ip    PLL_12MHZ  (
                .refclk  ( CLOCK_50  ),
                .rst     ( 1'b0      ),
                .outclk_0( clk_12mhz ));
  
 set_en   KEY_TO_ENABLE (
                                     .clk_i     ( clk_i2c      ),
                                     .edgerise_i( ~KEY[3]      ),
                                     .en_o      ( en_sys       ));
  
  edge_detect          KEY_TO_CONFIG_2 (
                                     .clk_i     ( clk_i2c                 ),
                                     .edgerise_i( en_sys                  ),
                                     .en_o      ( start_config            )); 

  
  /////////////////////////////////////////////////////
 set_and_show_demo_parameter ABCD
  (
                        .CLOCK_50(CLOCK_50),
                        .rst(rst_ni),
                        .KEY(KEY),
                        .hex_show(show_hex),
                        .choose (choose)  );
 ////////////////////////////////////////////////////
 // setup codec 
setup_codec  CODEC_SETUP  (
                            .clk_50mhz ( CLOCK_50      ),
                            .rst_ni    ( rst_ni        ),
                            .en_i      ( en_i          ),
                            .start_cf_i( start_config  ),
                            .i2c_sdin_o( FPGA_I2C_SDAT ),
                            .i2c_sclk_o( FPGA_I2C_SCLK ),
                            .cf_done_o ( done_config   ),
                            .clk_i2c_o ( clk_i2c       ));
// setting mode digital audio interface
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
                               .codec_dac_lrck_o    ( AUD_DACLRCK        ),
                               .clk_sample_o        (clk_sample));
////////////////////////////////////////////////////////////////////////////////
equalizer     AUD_EQUALIZER  (
                               .clk(clk_sample),
                               .rst(rst_ni),
                               .sam_in(data_no_eq),
                               .choose(choose),
                               . data_out(data_eq));
 assign  LEDR[9] = load_dac_dat;
  assign  LEDR[8] = en_sys;
  
  assign data_to_lineout = ( mode_sel ) ? data_eq : data_no_eq ;
endmodule