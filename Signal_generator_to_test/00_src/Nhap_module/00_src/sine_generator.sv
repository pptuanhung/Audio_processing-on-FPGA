module sine_generator #(
    parameter WIDTH = 24
)(

    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] freq_step,
    input wire [WIDTH-1:0] phase_offset,
    output wire signed [WIDTH-1:0] sin_out,
    output wire signed [WIDTH-1:0] cos_out
);
    
    reg [WIDTH-1:0] phase_accum;
    always @(posedge clk or posedge rst) begin
        if (rst)
            phase_accum <= 0;
        else
            phase_accum <= phase_accum + freq_step + phase_offset;
    end

    cordic_core #(.WIDTH(WIDTH)) cordic_inst (
        .clk(clk),
        .rst(rst),
        .phase_in(phase_accum),
        .sin_out(sin_out),
        .cos_out(cos_out)
    );

endmodule

