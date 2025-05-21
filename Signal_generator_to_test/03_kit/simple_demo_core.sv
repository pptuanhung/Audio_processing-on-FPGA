import Genwave_Pkg::*;

module simple_demo_core
   (
  input                   CLOCK_50,

  input          [3:0]    KEY,

  input          [9:0]    SW,

  output         [9:0]    LEDR,

  output         [6:0]    HEX0,
  output         [6:0]    HEX1,
  output         [6:0]    HEX2,
  output         [6:0]    HEX3,
  output         [6:0]    HEX4,
  output         [6:0]    HEX5,

  output                   AUD_ADCDAT,
  output                   AUD_ADCLRCK,
  output                   AUD_BCLK,
  output                  AUD_DACDAT,
  output                   AUD_DACLRCK,
  output                  AUD_XCK,

  output                  FPGA_I2C_SCLK,
  inout                   FPGA_I2C_SDAT
  );
  
  logic clk_12mhz;
  logic                  clk_i2c;
  logic rst_ni, en_i, ns_inject_i, en_sys;
  
  logic start_config, done_config;

  logic           [23:0] dig_wav;
  logic           [23:0] dig_wav_sampling;
  
  
  assign  rst_ni      =  KEY[3];
 
  set_en_when_edge_rise  KEY_TO_CONFIG  (
                            .clk_i     ( clk_i2c     ),
                            .edgerise_i( (SW[9]) ? ~KEY[1] : ~KEY[0] ),
                            .en_o      ( start_config ));
  
  assign LEDR[8] = (SW[9]) ? ~KEY[1] : ~KEY[0];
  
  assign  en_i        =  en_sys;
  
  assign  ns_inject_i =  SW[3];
  
  
  forever_set_en_when_edge_rise  KEY_TO_COUNT  (
                            .clk_i     ( clk_12mhz        ),
                            .edgerise_i( ~KEY[2]          ),
                            .en_o      ( en_sys           ));
  
  
  gen12Mhz    PLL_12MHZ  (
                .refclk  ( CLOCK_50  ),
                .rst     ( 1'b0      ),
                .outclk_0( clk_12mhz ));
  
  setup_codec  CODEC_SETUP  (
                   .clk_50mhz ( CLOCK_50      ),
                   .rst_ni    ( rst_ni        ),
                   .en_i      ( en_i          ),
                   .start_cf_i( start_config  ),
                   .i2c_sdin_o( FPGA_I2C_SDAT ),
                   .i2c_sclk_o( FPGA_I2C_SCLK ),
                   .cf_done_o ( done_config   ),
                   .clk_i2c_o ( clk_i2c       ));
  
  
///////////////////////////////////////////////////////////////////////////////
  
  logic clk_wave;
  
  scale_clock #(.FSC_WD(9)) SCALE_50M_FOR1K (
                      .clk_i  ( CLOCK_50       ),
                      .rst_ni ( rst_ni         ),
                      .scale_i( 9'd200         ), // 'd50 // A = 50M/(s_num*f) // s_num = 256
                      .clk_o  ( clk_wave       ));
  
///////////////////////////////////////////////////////////////////////////////  
  
  logic [15:0] sine_dat;
  logic [23:0] sine_dat_24;
  sine_gen # (.GEN_WD( 16 ) ) GEN_SINE (
                                        .clk_i ( clk_wave  ),
                                        .rst_ni( rst_ni    ),
                                        .wave_o( sine_dat   ));
  
  signed_data_extend #(.S_WD( 16 ), .L_WD( 24 )) SIGN_SINE (
                                        .data_i  ( sine_dat    ),
                                        .signed_i( 1           ),
                                        .data_o  ( sine_dat_24 ));
  
  
  
  assign dig_wav = sine_dat_24 * SW[7:0];
  
  logic  load_dac_dat;
  logic  sample_clk;

  always_ff@( posedge sample_clk, negedge rst_ni ) begin: SAMPLING_FF
    if      ( ~rst_ni      )  dig_wav_sampling <= 'b0;
    else if ( load_dac_dat )  dig_wav_sampling <= dig_wav;
  end
  
  //assign dig_wav_sampling = 24'h7FFFFF;
  
  p2s_buffer_rjm_codec    FPGA_CODEC_BUFFER   (
                               .clk_i         ( clk_12mhz ),
                               .rst_ni        ( rst_ni    ),
                               .en_i          ( en_i      ),
                               .paralel_data_i( dig_wav_sampling       ),
                               .load_i        ( load_dac_dat  ),
                               .seria_data_o  ( AUD_DACDAT    ),
                               .codec_bclk_o  ( AUD_BCLK      ),
                               .codec_lrck_o  ( AUD_DACLRCK   ),
                               .sample_clk_o  ( sample_clk    ));
  
  assign AUD_XCK = clk_12mhz;
  
  assign LEDR[0] = en_sys;
  
  
  forever_set_en_when_edge_rise  DONE_CF  (
                            .clk_i     ( CLOCK_50         ),
                            .edgerise_i( done_config      ),
                            .en_o      ( load_dac_dat     ));
  
  assign LEDR[9] = load_dac_dat;
  
  
  int   quan;
  logic led_sp_debug;
  always_ff@( posedge AUD_DACLRCK, negedge rst_ni ) begin: SAMPLING_DEBUG
    if      ( ~rst_ni      )   begin
                                  quan         <= 'b0;
                                  led_sp_debug <= 'b0;
                               end
    else if ( quan == 24000 )   begin
                                  quan         <= 0;
                                  led_sp_debug <= ~led_sp_debug;
                               end
    else                        begin
                                  quan         <= quan + 1;
                                  led_sp_debug <= led_sp_debug;
                               end
  end
  
  assign LEDR[2] = led_sp_debug;
  
  int nhat;
  logic led_sp_debug_01;
  always_ff@( posedge AUD_XCK, negedge rst_ni ) begin: DSP_DEBUG
    if      ( ~rst_ni      )   begin
                                  nhat         <= 'b0;
                                  led_sp_debug_01 <= 'b0;
                               end
    else if ( nhat == 12_000_000 )   begin
                                    nhat         <= 0;
                                  led_sp_debug_01 <= ~led_sp_debug_01;
                               end
    else                        begin
                                  nhat         <= nhat + 1;
                                  led_sp_debug_01 <= led_sp_debug_01;
                               end
  end
  
  assign LEDR[6] = led_sp_debug_01;
  
  
  int tin;
  logic led_sp_debug_02, clk_i2c_top;
  assign clk_i2c_top = clk_i2c;
  
  always_ff@( posedge clk_i2c_top, negedge rst_ni ) begin: I2C_DEBUG
    if      ( ~rst_ni      )   begin
                                  tin         <= 'b0;
                                  led_sp_debug_02 <= 'b0;
                               end
    else if ( tin == 200_000 )   begin
                                    tin         <= 0;
                                  led_sp_debug_02 <= ~led_sp_debug_02;
                               end
    else                        begin
                                  tin         <= tin + 1;
                                  led_sp_debug_02 <= led_sp_debug_02;
                               end
  end
  
  assign LEDR[7] = led_sp_debug_02;
  
endmodule