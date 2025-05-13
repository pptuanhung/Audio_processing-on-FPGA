module demo_sys
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
  logic            select_data;
  logic            select_noise;
  logic           [23:0] sample_from_linein;
   logic           [15:0] sample_from_sine_gen_16;
   logic           [23:0] sample_from_sine_gen;
   logic           [23:0] sample_data;
  logic           [23:0] sample_noise;
  logic            [23:0] data_to_lineout;
  /////////////////////////////////////////////////////
  assign  sample_data = (select_data)? sample_from_linein :24'b0;
  assign  sample_noise = (select_noise)? sample_from_sine_gen :24'b0;
  /////////////////////////////////////////////////////
   assign  rst_ni       =  KEY[3] | ~SW[0];
   assign  mode_sel     = SW[7];
   assign  select_data  = SW[9];
   assign  select_noise = SW[8];
////////////////////////////////////////////////////////7
  assign HEX0 = show_hex[0];
  assign HEX1 = show_hex[1];
  assign HEX2 = show_hex[2];
  assign HEX3 = show_hex[3];
  assign HEX4 = show_hex[4];
  assign HEX5 = show_hex[5];
  assign en_i = en_sys;
  
  assign LEDR[7:1] = SW[7:1];
  assign LEDR[0] = ~KEY[0];
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
 set_and_show_demo_parameter set_show
  (
                        .CLOCK_50(CLOCK_50),
                        .rst(rst_ni),
                        .KEY(KEY),
                        .hex_show(show_hex),
                        .choose (choose)
  );
 ////////////////////////////////////////////////////
sine_gen # ( .GEN_WD(16) ) sine // generating-data's width
  (
              .clk_50(CLOCK_50),
              .rst_ni(rst_ni),  
              .wave_o(sample_from_sine_gen_16)
  );
///////////////////////////////////////////////////gainsineifwant 
   assign sample_from_sine_gen = { {8{sample_from_sine_gen_16[15]}}, sample_from_sine_gen_16} * {17'b0 , SW[6:0]};
 
 /////////////////////////////////////////////////////
 // setup codec 
set_en  DONE_CF  (
                               .clk_i     ( CLOCK_50         ),
                               .edgerise_i( done_config      ),
                               .en_o      ( load_dac_dat     ));
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
                               .data_out(data_eq));
  assign  LEDR[9] = load_dac_dat;
  assign  LEDR[8] = en_sys;
  assign data_to_lineout = ( mode_sel ) ? data_eq : data_no_eq ;
  assign data_no_eq = sample_data + sample_noise;
endmodule