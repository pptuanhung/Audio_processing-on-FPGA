module cordic_core
#(parameter WIDTH = 24, ITERATIONS = 48)
(
    input wire clk,
    input wire rst,
    input wire signed [WIDTH-1:0] phase_in,
    output reg signed [WIDTH-1:0] sin_out,
    output reg signed [WIDTH-1:0] cos_out
);
    
    // Lookup table of arctan values scaled to fixed point
    reg signed [WIDTH-1:0] atan_table [0:ITERATIONS-1];
    initial begin
        atan_table[0]  = 24'h3243F6;
        atan_table[1]  = 24'h1DAC67;
        atan_table[2]  = 24'h0FADBA;
        atan_table[3]  = 24'h07F56E;
        atan_table[4]  = 24'h03FEAB;
        atan_table[5]  = 24'h01FFD5;
        atan_table[6]  = 24'h00FFF6;
        atan_table[7]  = 24'h007FFB;
        atan_table[8]  = 24'h003FFD;
        atan_table[9]  = 24'h001FFE;
        atan_table[10] = 24'h000FFF;
        atan_table[11] = 24'h0007FF;
        atan_table[12] = 24'h0003FF;
        atan_table[13] = 24'h0001FF;
        atan_table[14] = 24'h0000FF;
        atan_table[15] = 24'h00007F;
    end

    reg signed [WIDTH-1:0] x, y, z;
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sin_out <= 0;
            cos_out <= 0;
        end else begin
            x = 24'h4DBA76 ; // Precomputed 1.646760 * (2^23) scaling factor
            y = 0;
            z = phase_in;

            for (i = 0; i < ITERATIONS; i = i + 1) begin
                if (z >= 0) begin
                    z = z - atan_table[i];
                    x = x - (y >>> i);
                    y = y + (x >>> i);
                end else begin
                    z = z + atan_table[i];
                    x = x + (y >>> i);
                    y = y - (x >>> i);
                end
            end

            cos_out <= x;
            sin_out <= y;
        end
    end
endmodule
