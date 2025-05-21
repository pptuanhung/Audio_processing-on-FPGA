module i2c_protocol (
   input  logic         clk      ,
   input  logic         reset_n  ,
   input  logic         start    , 
   input  logic [6:0]   addr     ,
   input  logic         wr_rd    , // 0 is write 1 is read, but wm8131 only write
   input  logic [7:0]   data_st  , // first byte
   input  logic [7:0]   data_nd  , // second byte
   
   output logic busy             ,
   output logic done             ,

   inout        sclk             ,
   inout        sdin 
);

   logic [ 6:0]   addr_send;
   logic [ 7:0]   data_st_send,
                  data_nd_send;
   logic          wr_rd_send;
   logic          done_tmp,
                  busy_tmp,
                  sclk_tmp,
                  sdin_tmp;

   logic [  4:0]  count_q,
                  count_d;
   logic [26:0]   data;
   assign data = {addr_send, wr_rd_send, 1'b1, data_st_send, 1'b1, data_nd_send, 1'b1}; // 2-wire serial interface 
		// 7+1+1+8+1+8+1=27
   typedef enum logic [4:0] {
      IDLE        , 
      START       , // Sdat is low but Sclk still high
      START_CONT  , // Sdat and Sclk is low
      BUF_1       , // waiting posedge for sending data stable
      DATA_SEND_1 , // sending addr data
      DATA_SEND_2 ,
      DATA_SEND_3 ,
      DATA_SEND_4 ,
      BUF_2       ,
      STOP        ,
      DONE
   } state_t;

   state_t state, next_state; 

   always @(posedge start) begin 
      addr_send      <= addr;
      data_st_send   <= data_st;
      data_nd_send   <= data_nd;
      wr_rd_send     <= wr_rd;
   end

   // state transition
   always_ff @(posedge clk or negedge reset_n) begin 
      if (!reset_n) begin 
         state <= IDLE; // reset state
         count_q <= 5'd27;
      end else begin 
         state <= next_state; // next state <= presen state
         count_q <= count_d; // counter cycle 
      end
   end

   // output state transition
   always_comb begin 
      case (state) 
         IDLE: begin 
            if (start)  next_state = START;
            else        next_state = state;

            sclk_tmp = 1; 
            sdin_tmp = 1;
            count_d  = 5'd26;
            done     = 0;
            busy     = 0;
         end
         START: begin 
            next_state  = START_CONT;

            count_d  = count_q;
            sclk_tmp = 1;
            sdin_tmp = 0;
            done     = 0;
            busy     = 1;
         end
         START_CONT: begin 
            next_state  = BUF_1;

            count_d  = count_q;
            sclk_tmp = 0;
            sdin_tmp = 0;
            busy     = 1;
            done     = 0;
         end
         BUF_1: begin 
            next_state  = DATA_SEND_1;

            count_d  = count_q;
            sclk_tmp = 0;
            sdin_tmp = 0;
            busy     = 1;
            done     = 0;
         end
         DATA_SEND_1: begin 
            next_state  = DATA_SEND_2;

            count_d  = count_q;
            sclk_tmp = 0;
            sdin_tmp = data[count_q];
            busy     = 1;
            done     = 0;
         end
         DATA_SEND_2: begin 
            next_state  = DATA_SEND_3;

            count_d  = count_q;
            sclk_tmp = 1;
            sdin_tmp = data[count_q];
            busy     = 1;
            done     = 0;
         end
         DATA_SEND_3: begin 
            next_state  = DATA_SEND_4;

            count_d  = count_q;
            sclk_tmp = 1;
            sdin_tmp = data[count_q];
            busy     = 1;
            done     = 0;
         end
         DATA_SEND_4: begin 
            if (count_q == 0) next_state = BUF_2;
            else              next_state = DATA_SEND_1;

            count_d = count_q - 1;
            sclk_tmp = 0;
            sdin_tmp = data[count_q];
            busy     = 1;
            done     = 0;
         end
         BUF_2: begin 
            next_state  = STOP;

            count_d  = 26;
            sclk_tmp = 0;
            sdin_tmp = 0;
            busy     = 1;
            done     = 0;
         end
         STOP: begin 
            next_state  = DONE;

            count_d  = 5'd26;
            sclk_tmp = 1;
            sdin_tmp = 0;
            busy     = 1;
            done     = 0;
         end
         DONE: begin 
            next_state  = IDLE;

            count_d  = 26;
            sclk_tmp = 1;
            sdin_tmp = 1;
            busy     = 1;
            done     = 1;
         end
         default: begin
            next_state  = IDLE;

            count_d  = 26;
            sclk_tmp = 0;
            sdin_tmp = 0;
            busy     = 0;
            done     = 0;
         end
      endcase
   end

   assign sclk = (sclk_tmp) ? 1'b1 : 1'b0;
   assign sdin = (sdin_tmp) ? 1'bz : 1'b0;

endmodule 
