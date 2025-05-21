module i2c_controller (
    input  wire clk,
    input  wire rst_n,    // Active-low reset
    input  wire start,    // Start signal
    input  wire [23:0] i2c_data, // Data to send (24-bit)

    output wire i2c_sclk,  // I2C Clock output
    inout  wire i2c_sdat,  // I2C Data line (bidirectional)

    output reg done,      // Transaction complete flag
    output reg ack        // ACK received flag
);

    // Define FSM states
    typedef enum reg [2:0] {
        IDLE  = 3'b000,
        START = 3'b001,
        ACK0  = 3'b010,
        ACK1  = 3'b011,
        ACK2  = 3'b100,
        STOP  = 3'b101
    } state_t;

    state_t state, next_state;

    reg [23:0] data_reg;
    reg [4:0] bit_counter;
    reg [6:0] clk_divider;
    reg clock_en, sdat_out;
    reg [2:0] acks;

    // Output assignments
    assign i2c_sclk = (!clock_en) || clk_divider[6];
    assign i2c_sdat = (sdat_out) ? 1'bz : 1'b0; // Open-drain with pull-up

    // FSM State Transition
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM Next State Logic
    always_comb begin
        case (state)
            IDLE:  next_state = (start) ? START : IDLE;
            START: next_state = (bit_counter == 5'd8) ? ACK0 : START;
            ACK0:  next_state = (bit_counter == 5'd16) ? ACK1 : ACK0;
            ACK1:  next_state = (bit_counter == 5'd24) ? ACK2 : ACK1;
            ACK2:  next_state = STOP;
            STOP:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // FSM Output Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_counter <= 0;
            clk_divider <= 0;
            clock_en <= 0;
            sdat_out <= 1'b1;
            acks <= 3'b111;
            data_reg <= 0;
            done <= 0;
            ack <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    clock_en <= 0;
                    bit_counter <= 0;
                    sdat_out <= 1'b1;
                    if (start) begin
                        data_reg <= i2c_data;
                    end
                end

                START: begin
                    sdat_out <= 1'b0; // Start condition
                    clock_en <= 1'b1;
                end

                ACK0, ACK1, ACK2: begin
                    if (clk_divider == 7'd127) begin
                        if (bit_counter[4:0] == 5'd9 || bit_counter[4:0] == 5'd18 || bit_counter[4:0] == 5'd27 ) begin
                            case (stage)
				// receive acks
				5'd9:  acks[0] <= i2c_sdat;
				5'd18: acks[1] <= i2c_sdat;
				5'd27: acks[2] <= i2c_sdat;
				// before stop
				5'd28: clock_en <= 1'b0;
			    endcase
			    sdat_out<=1'b1;
                        end else begin
		                clk_divider <= 0;
		                bit_counter <= bit_counter + 1;
		                sdat_out <= data_reg[23]; // Send MSB first
		                data_reg <= {data_reg[22:0], 1'b0};
                    	end
                    end else begin
                        clk_divider <= clk_divider + 1;
                    end
                end

                STOP: begin
                    sdat_out <= 1'b0; // Stop condition
                    clock_en <= 0;
                    done <= 1;
                    ack <= (acks == 3'b000);
                end
            endcase
        end
    end

endmodule

