module i2c_codec_ctrl
  (
    input  logic i2c_clock_50,
    //input  logic rst_ni,
  
  
    input  logic [ 7:0] i2c_addr,
    input  logic [15:0] i2c_data,
    input  logic i2c_send_flag,

    inout  wire i2c_sda,

    output  logic i2c_busy,
    output  logic i2c_done,
    output  logic i2c_scl,
    output  logic i2c_clk
  );
  
    logic i2c_sda_ot; // out_temp
    logic i2c_sda_we;
    logic i2c_clk_en = 1'b0;
    logic clk_en     = 1'b0;
    logic ack_en     = 1'b0;
    logic clk_i2c    = 1'b0;
    logic get_ack    = 1'b0;
    logic  [3:0] i2c_fsm = 4'b0;

    int clk_prs, data_index;
  
  parameter READY         = 4'h0;
  parameter START         = 4'h1;

  parameter SEND_ADDR_I2C = 4'h2;
  parameter GET_ACK_ADDR  = 4'h3;

  parameter SEND_BYTE_158 = 4'h4;
  parameter GET_ACK_158   = 4'h5;

  parameter SEND_BYTE_70  = 4'h6;
  parameter GET_ACK_70    = 4'h7;

  parameter STOP          = 4'h8;
  
// generate two clocks for i2c and data transitions
  always_ff @(posedge i2c_clock_50) begin: SCALE_50M
    if    ( clk_prs < 250 )   clk_prs <= clk_prs + 1;
    else                      clk_prs <= 0;
  end
  
  always_ff @(posedge i2c_clock_50) begin: CLK_I2C_50DTCC
    if    ( clk_prs < 125 )   clk_i2c <= 1;
    else                      clk_i2c <= 0;
  end
  
  always_ff @(posedge i2c_clock_50) begin: ACK_EN // RISE AT 1/4 SCLK-cycle
    if    ( clk_prs == 62  )  ack_en <= 1;
    else                      ack_en <= 0;
  end
  
  always_ff @(posedge i2c_clock_50) begin: CLK_EN // RISE AT 3/4 SCLK-cycle
    if    ( clk_prs == 187 )  clk_en <= 1;
    else                      clk_en <= 0;
  end
  
/////////////////////////////////////////////////////////////////////////////////////////////
  
  always_ff @( posedge i2c_clock_50 ) begin: GEN_SCL
         if  ( i2c_clk_en ) i2c_scl <= clk_i2c;
         else               i2c_scl <= 1;
  end
  
/////////////////////////////////////////////////////////////////////////////////////////////
  
  
  always_ff @( posedge i2c_clock_50/*, posedge clk_en, posedge ack_en*/ ) begin: FSM_DAT_TRANS_WHILE_LOW_SCLK
    if       ( clk_en )
       begin
         case ( i2c_fsm )
          READY         : begin
                               i2c_sda_ot  <= 1'b1;                                               // stop condition, comeback from STOP
                               i2c_busy <= 1'b0;
                               i2c_done <= 1'b0;
                               if      ( i2c_send_flag   )     begin
                                                                   i2c_fsm  <= START;
                                                                   i2c_busy <= 1'b1;
                                                               end
                          end
          START         : begin
                               i2c_sda_ot    <= 1'b0;                                             // start conditions
                               data_index <= 7;
                               i2c_fsm    <= SEND_ADDR_I2C;
                          end
          SEND_ADDR_I2C : begin
                               i2c_clk_en    <= 1'b1;
                               if      ( get_ack )             begin
                                                                   get_ack    <= 1'b0;
                                                                   i2c_fsm    <= GET_ACK_ADDR;
                                                                   i2c_sda_ot <= 1'bz;
                                                               end
                               else if ( data_index > 0 )      begin
                                                                   data_index <= data_index - 1;
                                                                   i2c_sda_ot    <= i2c_addr[data_index];
                                                               end
                               else                            begin
                                                                   get_ack    <= 1'b1;
                                                                   i2c_sda_ot    <= i2c_addr[data_index];
                                                               end
                          end
          SEND_BYTE_158 : begin
                               if      ( get_ack )             begin
                                                                   get_ack    <= 1'b0;
                                                                   i2c_fsm    <= GET_ACK_158;
                                                                   i2c_sda_ot    <= 1'bz;
                                                               end
                               else if ( data_index > 8 )      begin
                                                                   data_index <= data_index - 1;
                                                                   i2c_sda_ot    <= i2c_data[data_index];
                                                               end
                               else                            begin
                                                                   get_ack    <= 1'b1;
                                                                   i2c_sda_ot    <= i2c_data[data_index];
                                                               end
                          end
          SEND_BYTE_70  : begin
                               if      ( get_ack )             begin
                                                                   get_ack    <= 1'b0;
                                                                   i2c_fsm    <= GET_ACK_70;
                                                                   i2c_sda_ot    <= 1'bz;
                                                               end
                               else if ( data_index > 0 )      begin
                                                                   data_index <= data_index - 1;
                                                                   i2c_sda_ot    <= i2c_data[data_index];
                                                               end
                               else                            begin
                                                                   get_ack    <= 1'b1;
                                                                   i2c_sda_ot    <= i2c_data[data_index];
                                                               end
                          end
          STOP          : begin
                               i2c_clk_en <= 1'b0;
                               i2c_sda_ot <= 1'b0;
                               i2c_done   <= 1'b1;
                               i2c_fsm    <= READY;
                          end
          default       : begin
                          end
         endcase
       end
  //end
  
//  always_ff @( posedge i2c_clock_50, posedge ack_en ) begin: FSM_ACK_GET_WHILE_HIGH_SCLK
    else if  ( ack_en )
       begin
         case ( i2c_fsm )
          GET_ACK_ADDR  : begin
                               if    ( ~i2c_sda )  begin
                                                       i2c_fsm    <= SEND_BYTE_158;
                                                       data_index <= 15;
                                                   end
                               else                begin
                                                       i2c_fsm    <= READY;
                                                       i2c_clk_en <= 1'b0;
                                                   end
                          end
          GET_ACK_158   : begin
                               if    ( ~i2c_sda )  begin
                                                       i2c_fsm    <= SEND_BYTE_70;
                                                       data_index <= 7;
                                                   end
                               else                begin
                                                       i2c_fsm    <= READY;
                                                       i2c_clk_en <= 1'b0;
                                                   end
                          end
          GET_ACK_70    : begin
                               if    ( ~i2c_sda )  begin
                                                       i2c_fsm    <= STOP;
                                                   end
                               else                begin
                                                       i2c_fsm    <= READY;
                                                       i2c_clk_en <= 1'b0;
                                                   end
                          end
          default       : begin
                          end
         endcase
       end
  end
  
  assign i2c_sda_we = ( i2c_fsm == GET_ACK_ADDR) || ( i2c_fsm == GET_ACK_158) || ( i2c_fsm == GET_ACK_70) ;
  assign i2c_sda    = ( i2c_sda_we ) ? 1'bz : i2c_sda_ot ; // we = 1 while write to i2c_sda, high-logic for getting ack
  assign i2c_clk    =   clk_i2c ;
  
endmodule