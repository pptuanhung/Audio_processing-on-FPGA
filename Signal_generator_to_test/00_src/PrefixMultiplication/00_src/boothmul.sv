module boothmul(
    input signed [15:0] a, b,
    output signed [31:0] c
);
    wire signed [15:0] A[0:16], Q[0:16];
    wire q[0:16];
    assign A[0] = 16'b0;
    assign Q[0] = a;
    assign q[0] = 1'b0;
    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : booth_steps
            booth_substep step(A[i], Q[i], b, q[i], A[i+1], Q[i+1], q[i+1]);
        end
    endgenerate
    
    assign c = {A[16], Q[16]};
endmodule
