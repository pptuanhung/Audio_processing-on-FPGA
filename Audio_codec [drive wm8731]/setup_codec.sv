module setup_codec
   (
    input  logic  clk_50mhz,
    input  logic  rst_ni,
    input  logic  en_i,
    
    input  logic  start_cf_i,
    
     inout wire   i2c_sdin_o,
    output logic  i2c_sclk_o,
    output logic  cf_done_o,
    output logic  clk_i2c_o
   );

  logic  i2c_busy;
  logic  i2c_done;
  logic         clk_i2c;
  logic  send_start_i2c;
  logic  [15:0] cf_data;
  
  i2c_codec_ctrl I2C_PROTOCOL (
                                     .i2c_busy     ( i2c_busy       ),
                                     .i2c_send_flag( send_start_i2c ),
                                     .i2c_done     ( i2c_done       ),
                                     .i2c_addr     ( 8'b00110100    ),
                                     .i2c_data     ( cf_data        ),
                                     .i2c_clock_50 ( clk_50mhz      ),
                                     .i2c_scl      ( i2c_sclk_o     ),
                                     .i2c_sda      ( i2c_sdin_o     ),
                                     .i2c_clk      ( clk_i2c        ));
  
  assign clk_i2c_o = clk_i2c;
  
  codec_config_by_i2c  CONFIG_DATA  (
                                     .clk_i2c         ( clk_i2c        ),
                                     .rst_ni          ( rst_ni         ),
                                     .en_i            ( en_i           ),
                                     .start_cf_i      ( start_cf_i     ),
                                     .i2c_busy_i      ( i2c_busy       ),
                                     .i2c_done_i      ( i2c_done       ),
                                     .send_start_i2c_o( send_start_i2c ),
                                     .cf_data_o       ( cf_data        ),
                                     .cf_done_o       ( cf_done_o      ));
  
endmodule