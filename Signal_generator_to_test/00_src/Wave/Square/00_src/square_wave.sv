module square_wave (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] phase_step, 
    output wire  square_out
);

    wire [9:0] phase_acc;
    wire [9:0]  phase_addr;

    // Phase accumulator
    phase_accumulator square_phase_acc (
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .phase_out(phase_acc)
    );

    assign phase_addr = phase_acc;

    // square lookup table
    square_lut square_lut (
        .clk(clk),
        .phase_addr(phase_addr),
        .square_value(square_out)
    );

endmodule

