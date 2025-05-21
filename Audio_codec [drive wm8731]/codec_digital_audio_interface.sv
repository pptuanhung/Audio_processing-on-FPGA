module codec_digital_audio_interface
  (
    input  logic        clk_i, //12Mhz
    input  logic        rst_ni,
    input  logic        en_i,
    
    input  logic        load_i,
    
    input  logic [23:0] data_to_lineout_i,
    
    input  logic        codec_aud_adc_dat_i,
    output logic        codec_bclk_o,
    output logic        codec_dac_lrck_o,
    output logic        codec_adc_lrck_o,
    output logic        codec_xck_o,
    output logic        codec_aud_dac_dat_o,
    output logic        clk_sample_o,
 
    output logic [23:0] sample_from_linein_o
  );
  
  logic    clk_sample;
  logic [23:0] data_from_linein_t;
  logic [23:0] sample_to_lineout_t;
  
  audio_io_buffer_rjm_codec_vers2  FPGA_CODEC_BUFFER  (
                               .clk_i         ( clk_i     ),
                               .rst_ni        ( rst_ni    ),
                               .en_i          ( en_i      ),
                               .load_i        ( load_i    ),
                               .adc_serial_data_i  ( codec_aud_adc_dat_i  ),
                               .dac_parallel_data_i( sample_to_lineout_t  ),
                               .dac_serial_data_o  ( codec_aud_dac_dat_o  ),
                               .adc_parallel_data_o( data_from_linein_t   ),
                               .codec_xck_o        ( codec_xck_o          ),
                               .codec_bclk_o       ( codec_bclk_o         ),
                               .codec_lrck_o       ( codec_dac_lrck_o     ),
                               .sample_clk_o       ( clk_sample           ));
  
  assign codec_adc_lrck_o = codec_dac_lrck_o;
  assign clk_sample_o = clk_sample;
  
  always_ff@( posedge clk_sample, negedge rst_ni ) begin:       SAMPLING_BUFFER
    if      ( ~rst_ni      )  begin
                                  sample_to_lineout_t  <= 'b0;
                                  sample_from_linein_o <= 'b0;
                             end
    else if ( load_i       )  begin
                                  sample_to_lineout_t  <= data_to_lineout_i;
                                  sample_from_linein_o <= data_from_linein_t;
                             end
    else                       begin
                                  sample_to_lineout_t  <= sample_to_lineout_t;
                                  sample_from_linein_o <= sample_from_linein_o;
                             end
  end
  
  
endmodule
 
////////////////////////////       ////////////////////////////       ////////////////////////////
////////////////////////////       ////////////////////////////       ////////////////////////////
////////////////////////////       ////////////////////////////       ////////////////////////////
  
module audio_io_buffer_rjm_codec_vers2 // for R_ight J_ustified M_ode // not changes
  (
    input  logic        clk_i, //12Mhz
    input  logic        rst_ni,
    input  logic        en_i,
    
    input  logic          load_i,
    input  logic          adc_serial_data_i,
    input  logic [23:0] dac_parallel_data_i,
  
    output logic          dac_serial_data_o,
    output logic [23:0] adc_parallel_data_o,
  
    output logic  codec_xck_o,
    output logic  codec_bclk_o,
    output logic  codec_lrck_o,
    output logic  sample_clk_o
  );
  
  parameter READY    = 2'd0;
  parameter WAITING  = 2'd1;
  parameter SENDING  = 2'd2;
///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////
  logic  [7:0] clk_count_debug;
  always_ff@(posedge clk_i, negedge rst_ni) begin: COUNT_DEBUG
    if      ( ~rst_ni )  begin
                            clk_count_debug <= 'b0;
                         end
    else if (  en_i )    begin
                            clk_count_debug <= ( load_i  ) ? ( clk_count_debug + 1 ) : clk_count_debug;
                         end
  end

///////////////////////////////////////////////
///////////////////////////////////////////////
///////////////////////////////////////////////

/////////////////////////////////////////////////////////////* FSM */ BEGIN 
  
  logic  [7:0] clk_count;
  logic  sdata_p2s;
  logic  [23:0] pdata_s2p;

  
  logic  [1:0] now_state, nxt_state; // now - next state
  logic  pre_lrck, bclk , lrck;
  
  logic  sending     , left_2_right;
  logic  count_up_101, count_up_125;
  
  assign count_up_101 = ~|(clk_count ^ {8'd101}); // set when count clk to 121
  assign count_up_125 = ~|(clk_count ^ {8'd125}); // set when count clk to 125
  
  
  always_ff@(posedge clk_i, negedge rst_ni) begin: LRCK_SOS
    if      (~rst_ni)  begin
                            left_2_right <= 1'b0;
                       end
    else               begin
                            left_2_right <=  count_up_125; //  send_out_24b
                       end
  end
  
  always_ff@(posedge clk_i, negedge rst_ni) begin: STATE_TRANS
    if      ( ~rst_ni )  begin
                            now_state <= READY;
                            clk_count <= 8'b0;
                            pre_lrck  <= 1'b0;
                         end
    else if (  en_i )    begin
                            now_state <= nxt_state;
                            clk_count <= ( count_up_125 ) ? 8'b1 : ( load_i ) ? ( clk_count + 1 ) : clk_count;
                            pre_lrck  <= lrck;
                         end
  end
  
  always_comb begin: CASE_OF_STATES
   case ( now_state )
    READY     : begin
                 if      ( load_i  )     begin
                                                    nxt_state = WAITING;
                                                    lrck      = 1'b1;
                                                    sending   = 1'b0;
                                         end
                 else                      begin
                                                    nxt_state = READY;
                                                    lrck      = 1'b0;
                                                    sending   = 1'b0;
                                           end
                end
    WAITING   : begin
                 if      ( count_up_101 )  begin
                                                    nxt_state = SENDING;
                                                    lrck      = pre_lrck;
                                                    sending   = 1'b0;
                                           end
                 else if ( left_2_right )  begin
                                                    nxt_state = WAITING;
                                                    lrck      = ~pre_lrck;
                                                    sending   = 1'b0;
                                           end
                 else                      begin
                                                    nxt_state = WAITING;
                                                    lrck      = pre_lrck;
                                                    sending   = 1'b0;
                                           end
                end
    SENDING  : begin
                 if      ( count_up_125 )  begin
                                                    nxt_state = WAITING;
                                                    lrck      = pre_lrck;
                                                    sending   = 1'b1;
                                           end
                 else                      begin
                                                    nxt_state = SENDING;
                                                    lrck      = pre_lrck;
                                                    sending   = 1'b1;
                                           end
                end
    default   : begin
                                                    nxt_state = READY;
                                                    lrck      = 1'b0;
                                                    sending   = 1'b0;
                end
  endcase
  end
/////////////////////////////////////////////////////////////* FSM */ END
  
  
  
  
/////////////////////////////////////////////////////////////* PISO */ BEGIN

 // assign bclk  = ( ~sending ) ? 1'b0 : ( load_i ) ? ( ~clk_i ) : 1'b1;
  assign bclk  = ( load_i ) ? ( ~clk_i ) : 1'b1;
  
  
  piso_shift_reg #(.WD(24)) PISO_REG (
                                           .clk_i   ( clk_i     ),
                                           .rst_ni  ( rst_ni    ),
                                           .en_i    ( en_i      ),
                                           .wren_i  ( sending   ),
                                           .pdata_i ( dac_parallel_data_i ),
                                           .sdata_o ( sdata_p2s           ));

/////////////////////////////////////////////////////////////* PISO */ END
  
/////////////////////////////////////////////////////////////* SIPO */ BEGIN
  
  sipo_shift_reg #(.WD(24)) SIPO_REG (
                                           .clk_i   ( clk_i             ),
                                           .rst_ni  ( rst_ni            ),
                                           .en_i    ( en_i              ),
                                           .wren_i  ( sending           ),
                                           .sdata_i ( adc_serial_data_i ),
                                           .pdata_o ( pdata_s2p         ));

/////////////////////////////////////////////////////////////* SIPO */ END
  
  
/////////////////////////////////////////////////////////////* OUTPUT */ BEGIN

  assign codec_bclk_o        = bclk;
  assign codec_lrck_o        = lrck;
  assign codec_xck_o         = clk_i;
  assign dac_serial_data_o   = ( sending ) ? sdata_p2s : 1'b0;
  assign adc_parallel_data_o =  pdata_s2p;
  assign sample_clk_o        = lrck;
  
/////////////////////////////////////////////////////////////* OUTPUT */ END

endmodule
