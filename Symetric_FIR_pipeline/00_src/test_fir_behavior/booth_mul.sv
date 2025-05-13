module booth_mul(
    input  logic signed [24:0] a,  // multiplicand (25-bit)
    input  logic signed [15:0] b,  // multiplier (16-bit)
    output logic signed [41:0] c   // result (41-bit)
);

    // Accumulator and partial product arrays
    wire signed [24:0] A [0:16];  // Accumulator (25-bit)
    wire signed [15:0] Q [0:16];  // Partial product (16-bit)
    wire               q [0:16];  // Booth's algorithm q bits

    // Initialize the first values of A, Q, and q
    assign A[0] = 25'd0;  // Initialize A to 0
    assign Q[0] = b;      // Set multiplier to Q[0]
    assign q[0] = 1'b0;   // Set initial q0 to 0

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : booth_steps
            // Execute the booth step for each iteration
            booth_step step(
                .a(A[i]),     // A is the accumulator
                .Q(Q[i]),     // Q is the partial product
                .m(a),        // a is the multiplicand (25-bit)
                .q0(q[i]),    // Previous q bit
                .f25(A[i+1]), // New accumulator
                .l16(Q[i+1]), // New Q
                .cq0(q[i+1])  // Carry out for q
            );
        end
    endgenerate

    // Concatenate A[16] (25-bit) and Q[16] (16-bit) to form final product (41-bit)
    assign c = {1'b0,A[16], Q[16]};  // Combine final values of A and Q to get the 41-bit result

endmodule
