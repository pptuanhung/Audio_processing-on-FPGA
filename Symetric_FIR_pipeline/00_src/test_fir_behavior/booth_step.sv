module booth_step(
    input  wire signed [24:0] a,      // Accumulator (25-bit)
    input  wire signed [15:0] Q,      // Partial product (16-bit)
    input  wire signed [24:0] m,      // Multiplicand (25-bit)
    input  wire        q0,            // Previous Q bit
    output reg  signed [24:0] f25,    // New accumulator (25-bit)
    output reg  signed [15:0] l16,    // Shifted Q (16-bit)
    output reg         cq0            // new q0
);

    reg signed [24:0] addam, subam;

    always @(*) begin
        addam = a + m;  // Add accumulator and multiplicand
        subam = a - m;  // Subtract accumulator and multiplicand
        cq0 = Q[0];     // The least significant bit of Q

        // Booth's algorithm steps
        case ({Q[0], q0})
            2'b00, 2'b11: begin
                l16 = Q >>> 1;         // Arithmetic right shift Q
                l16[15] = a[0];        // Set MSB of shifted Q to MSB of accumulator
                f25 = a >>> 1;         // Arithmetic right shift accumulator
            end
            2'b10: begin
                l16 = Q >>> 1;         // Shift Q
                l16[15] = subam[0];    // Set MSB to the least significant bit of subtraction result
                f25 = subam >>> 1;     // Shift subtraction result
            end
            2'b01: begin
                l16 = Q >>> 1;         // Shift Q
                l16[15] = addam[0];    // Set MSB to the least significant bit of addition result
                f25 = addam >>> 1;     // Shift addition result
            end
        endcase
    end
endmodule
