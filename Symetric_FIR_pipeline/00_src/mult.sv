module mult #(
    parameter DATA_W  = 25,   // pair_sum width (25-bit)
    parameter COEFF_W = 16,   // h[i] width (16-bit)
    parameter TAP      = 51   // number of multipliers
)(
    input  logic signed [DATA_W-1:0]  pair_sum [0:TAP-1],    // Array of pair sums (25-bit)
    input  logic signed [COEFF_W-1:0] h       [0:TAP-1],    // Array of coefficients (16-bit)
    output logic signed [41:0] product [0:TAP-1]// Array of product (41-bit)
);

    genvar i;
    generate
        for (i = 0; i < TAP; i = i + 1) begin : booth_mults
            booth_mul booth_inst (
                .a(pair_sum[i]),     // 25-bit multiplicand from pair_sum
                .b(h[i]),            // 16-bit multiplier from h
                .c(product[i])       // 41-bit output (concatenated A and Q from Booth multiplier)
            );
        end
    endgenerate

endmodule
