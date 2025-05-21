module sawtooth_wave (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] phase_step, 
    output wire [15:0] sawtooth_out
);

    wire [9:0] phase_acc;
    wire [9:0]  phase_addr;

    // Phase accumulator
    phase_accumulator sawtooth_phase_acc (
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .phase_out(phase_acc)
    );

    assign phase_addr = phase_acc;

    // sawtooth lookup table
    sawtooth_lut sawtooth_lut (
        .clk(clk),
        .phase_addr(phase_addr),
        .sawtooth_value(sawtooth_out)
    );

endmodule

