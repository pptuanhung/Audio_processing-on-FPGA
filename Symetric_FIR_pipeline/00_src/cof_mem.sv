// Coefficient ROM module for FIR filter (output full array, no addr needed)

module cof_mem #(
    parameter WIDTH     = 16,
    parameter NUM_TAPS  = 51,
    parameter FILE_NAME = "../00_src/cof.txt"
)(
    input  logic clk,
    input  logic rst_n,
    output logic signed [WIDTH-1:0] data_out [0:NUM_TAPS-1]
);

    // Internal ROM memory
    logic signed [WIDTH-1:0] mem [0:NUM_TAPS-1];

    // Load coefficients from external file
    initial begin
        $readmemh(FILE_NAME, mem);
    end

    // Drive full array to output
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_out <= '{default:0};
        else
            data_out <= mem ;
    end

endmodule
