module  codec_config_by_i2c
   (
    input  logic  clk_i2c,
    input  logic  rst_ni,
    input  logic  en_i,
    
    input  logic  start_cf_i,
    
    input  logic  i2c_busy_i,
    input  logic  i2c_done_i,
    
    output logic  send_start_i2c_o,
    output logic  [15:0] cf_data_o,
    output logic  cf_done_o
   );
  
  
  parameter READY      = 2'd0;
  parameter SEND_START = 2'd1;
  parameter CHECK_ACK  = 2'd2;
  parameter DONE       = 2'd3;
  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  logic  [1:0] now_state, nxt_state; // now - next state
  
  logic send_start_i2c_t;
  
  logic         reg_nxt, reg_done, reg_rstn;
  logic  [ 3:0] reg_index;
  logic  [15:0] reg_setup [9:0];
  logic         i2c_nack;

  
  initial begin
      reg_setup[0] = 16'h1e00; //R15 reset all
      reg_setup[1] = 16'h0c10; //R6  Power up EX OUTPD
      reg_setup[2] = 16'h0579; //R2  LV 0dB balance
      reg_setup[3] = 16'h0779; //R3  RV 0dB balance
      reg_setup[4] = 16'h0812; //R4  mute ADC, on DAC, ban mic bypass 
      reg_setup[5] = 16'h0a00; //R5  
      reg_setup[6] = 16'h0e08; //R7  24bit MSB first
      reg_setup[7] = 16'h1001; //R8  USB mode, MCLK 12Mhz, 48Khz sampling
      reg_setup[8] = 16'h1201; //R9  active 
      reg_setup[9] = 16'h0c00; //R6  OUTPD
  end
  
  
  always_ff@(posedge clk_i2c, negedge reg_rstn) begin: REG_OUT
    if      ( ~reg_rstn )  begin
                            reg_index <= 4'b0;
                           end
    else if (  reg_nxt  )  begin
                            reg_index <= reg_index + 1;
                           end
  end
  
  assign cf_data_o = reg_setup [ reg_index ];
  assign reg_done  =          ~|(reg_index ^ 4'hA);
  assign reg_rstn  = rst_ni && ~i2c_nack && ~( ( now_state == DONE ) && ( nxt_state == READY ) );
  
  assign reg_nxt   = ( now_state == CHECK_ACK ) && ( nxt_state == SEND_START );
  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  assign  i2c_nack = (~|( now_state ^ CHECK_ACK )) && ~i2c_busy_i;  //  wait for getting ack but i2c not busy
  
  always_ff@(posedge clk_i2c, negedge rst_ni) begin: STATE_TRANS
    if      ( ~rst_ni )  begin
                            now_state <= READY;
                         end
    else if (  en_i )    begin
                            now_state <= nxt_state;
                         end
  end

  always_comb begin: CASE_OF_STATES
   case ( now_state )
    READY      : begin
                         send_start_i2c_t = 1'b0;
                         cf_done_o        = 1'b0;
                         nxt_state        = ( start_cf_i && ~i2c_busy_i ) ? SEND_START : READY;
                 end
    SEND_START : begin
                         send_start_i2c_t = 1'b1;
                         cf_done_o        = 1'b0;
                         nxt_state        = ( reg_done ) ? DONE : CHECK_ACK;
                 end
    CHECK_ACK    : begin
                         send_start_i2c_t = 1'b0;
                         cf_done_o        = 1'b0;
                         nxt_state        = ( ~i2c_done_i && i2c_busy_i ) ? CHECK_ACK : SEND_START;
                 end
    DONE       : begin
                         send_start_i2c_t = 1'b0;
                         cf_done_o        = 1'b1;
                         nxt_state        = READY;
                 end
    default    : begin
                         send_start_i2c_t = 1'b0;
                         cf_done_o        = 1'b0;
                         nxt_state        = READY;
                 end
  endcase
  end
  
  assign send_start_i2c_o = ~reg_done && send_start_i2c_t;
  
endmodule
