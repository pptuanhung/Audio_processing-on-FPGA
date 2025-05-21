module i2c_av_config (
    input clk,
    input reset,

    output i2c_sclk,
    inout  i2c_sdat,

    output [3:0] status
);

reg [23:0] i2c_data;
reg [15:0] lut_data,lut_data_reg;
reg [3:0]  lut_index;

parameter LAST_INDEX = 4'ha;

reg  i2c_start ;
wire i2c_done;
wire i2c_ack;

i2c_controller control (
    .clk (clk),
    .i2c_sclk (i2c_sclk),
    .i2c_sdat (i2c_sdat),
    .i2c_data (i2c_data),
    .start (i2c_start),
    .done (i2c_done),
    .ack (i2c_ack)
);

always @(*) begin
        case (lut_index)
            4'd0:  lut_data = 16'h0c10;// power on everything except out
            4'd1:  lut_data = 16'h0017; // left input
            4'd2:  lut_data = 16'h0217; // right input
            4'd3:  lut_data = 16'h0479; // left output
            4'd4:  lut_data = 16'h0679; // right output
            4'd5:  lut_data = 16'h08d4; // analog path
            4'd6:  lut_data = 16'h0a04; // digital path
            4'd7:  lut_data = 16'h0e01; // digital IF
            4'd8:  lut_data = 16'h1020; // sampling rate
            4'd9:  lut_data = 16'h0c00; // power on everything
            4'd10: lut_data = 16'h1201; // activate
            default: lut_data = 16'b0; // Default case
        endcase
    end
always @(posedge clk) begin
	lut_data_reg <= lut_data;
end

reg [1:0] control_state = 2'b00;

assign status = lut_index;

always @(posedge clk) begin
    if (reset) begin
        lut_index <= 4'd0;
        i2c_start <= 1'b0;
        control_state <= 2'b00;
    end else begin
        case (control_state)
            2'b00: begin
                i2c_start <= 1'b1;
                i2c_data <= {8'h34, lut_data};
                control_state <= 2'b01;
            end
            2'b01: begin
                i2c_start <= 1'b0;
                control_state <= 2'b10;
            end
            2'b10: if (i2c_done) begin
                if (i2c_ack) begin
                    if (lut_index == LAST_INDEX)
                        control_state <= 2'b11;
                    else begin
                        lut_index <= lut_index + 1'b1;
                        control_state <= 2'b00;
                    end
                end else
                    control_state <= 2'b00;
            end
        endcase
    end
end

endmodule
