module i2c_slave (
    input clk,
    input i2c_sclk,
    inout i2c_sdat,
    output [23:0] i2c_data
);

reg [2:0] state = 3'b000;
reg last_sclk;
reg last_sdat;
reg [23:0] shift_in;
reg [4:0] bit_count;
reg sdat = 1'bz;

wire sdat_falling = !i2c_sdat && last_sdat;
wire sdat_rising  = i2c_sdat && !last_sdat;
wire sclk_falling = !i2c_sclk && last_sclk;
wire sclk_rising  = i2c_sclk && !last_sclk;

assign i2c_sdat = sdat;
assign i2c_data = shift_in;

pullup (i2c_sdat);

always @(posedge clk) begin
    case (state)
        3'b000: if (i2c_sclk && sdat_falling) begin
            state <= 3'b001;
            shift_in <= 24'd0;
            bit_count <= 5'd0;
        end
        3'b001: if (sclk_rising) begin
            shift_in <= {shift_in[22:0], i2c_sdat};
            if (bit_count[2:0] == 3'b111)
                state <= 3'b010;
            else
                bit_count <= bit_count + 1'b1;
        end
        3'b010: if (sclk_falling) begin
            sdat <= 1'b0;
            state <= 3'b011;
        end
        3'b011: if (sclk_falling) begin
            sdat <= 1'bz;
            if (bit_count == 5'd23)
                state <= 3'b100;
            else begin
                state <= 3'b001;
                bit_count <= bit_count + 1'b1;
            end
        end
    endcase
    last_sclk <= i2c_sclk;
    last_sdat <= i2c_sdat;
end

endmodule
