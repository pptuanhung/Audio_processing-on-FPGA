module lfsr #(
    parameter SEED_DEFAULT = 4'h2  // Default seed value
)(
    input wire clk, clk_div,
    input wire rst_n,
    input wire gain_inc, gain_dec,  // Noise amplitude control (0 to 15)
    output reg [7:0] noise_out   // 4-bit noise output
);

    // 4-bit shift register
    reg [3:0] lfsr_reg;
    reg [3:0] noise_gain;

    // Gain control counter
    always @(posedge clk) begin
        if (!rst_n) begin
            noise_gain <= 4'd1; // Reset to 1 to prevent loss of noise
        end else begin
            case ({gain_inc, gain_dec})
                2'b10: if (noise_gain < 4'd15) noise_gain <= noise_gain + 1; // Increase gain if below 15
                2'b01: if (noise_gain > 4'd1) noise_gain <= noise_gain - 1;  // Decrease gain if above 1
                default: noise_gain <= noise_gain; // Hold the current value
            endcase
        end
    end

    // Feedback polynomial: x^4 + x^3 + 1
    wire feedback = lfsr_reg[3] ^ lfsr_reg[2];

    always @(posedge clk_div or negedge rst_n) begin
        if (!rst_n) begin
            lfsr_reg <= SEED_DEFAULT; // Initialize with SEED_DEFAULT parameter
        end else begin
            lfsr_reg <= {lfsr_reg[2:0], feedback}; // Shift register update
        end
    end

    // Scale noise amplitude
    always @(posedge clk_div) begin
        noise_out <= ((lfsr_reg * noise_gain)); // Scale and maintain 4-bit output
    end

endmodule
