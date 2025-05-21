module booth_substep(
    input wire signed [15:0] a, Q, m,
    input wire q0,
    output reg signed [15:0] f16, l16,
    output reg cq0
);
    reg signed [15:0] addam, subam;
    always @(*) begin
        addam = a + m;
        subam = a - m;
        cq0 = Q[0];
        case ({Q[0], q0})
            2'b00, 2'b11: begin
                l16 = Q >> 1;
                l16[15] = a[0];
                f16 = a >>> 1;
            end
            2'b10: begin
                l16 = Q >> 1;
                l16[15] = subam[0];
                f16 = subam >>> 1;
            end
            2'b01: begin
                l16 = Q >> 1;
                l16[15] = addam[0];
                f16 = addam >>> 1;
            end
        endcase
    end
endmodule
