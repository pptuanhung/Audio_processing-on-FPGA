module noise_generator #(
    parameter SEED_DEFAULT = 4'h2  // Default initialization value
)(
    input wire clk,
    input wire rst_n,
    input wire noise_gain_inc,   // Increase noise amplitude
    input wire noise_gain_dec,   // Decrease noise amplitude
    input wire noise_freq_inc,   // Increase noise frequency
    input wire noise_freq_dec,   // Decrease noise frequency
    output reg  [7:0] noise_out,  // 8-bit noise output
    output wire [7:0] analog_noise // Analog output signal
);

    // Internal signals
    reg clk_out;
    wire [3:0] lfsr_noise;

    // Assign analog noise output
    assign analog_noise = noise_out;

    // Frequency control using clock divider
    clk_div clk_div_inst (
        .clk(clk),
        .rst(~rst_n),
        .freq_inc(noise_freq_inc),
        .freq_dec(noise_freq_dec),
        .clk_out(clk_out)
    );

    // Instantiate 4-bit LFSR
    lfsr #(.SEED_DEFAULT(SEED_DEFAULT)) lfsr_inst (
        .clk_div(clk_out),
        .clk(clk),
        .rst_n(rst_n),
        .gain_inc(noise_gain_inc),
        .gain_dec(noise_gain_dec),
        .noise_out(noise_out)
    );

endmodule

