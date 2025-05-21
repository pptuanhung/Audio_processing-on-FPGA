module pair #(
    parameter WIDTH = 24,  // sample_in width
    parameter TAP   = 101  // number of taps
)(
    input  logic signed [WIDTH-1:0] sample_in [0:TAP-1],   // Array of input samples (24-bit)
    output logic signed [WIDTH:0]   sum_out   [0:(TAP-1)/2]  // 25-bit sum for each pair
);

    genvar i;
    generate
        for (i = 0; i <= (TAP-1)/2; i = i + 1) begin : gen_pair_add
            // Add the pair of values, result is 25-bit to accommodate overflow
            assign sum_out[i] = sample_in[i] + sample_in[TAP-1 - i];
        end
    endgenerate

endmodule
