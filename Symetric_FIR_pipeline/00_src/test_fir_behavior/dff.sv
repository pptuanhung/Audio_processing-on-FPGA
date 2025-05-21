module dff #(
    parameter WIDTH = 40
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [WIDTH-1:0] d,
    output logic signed [WIDTH-1:0] q
);
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n)
            q <= '0;
        else
            q <= d;
endmodule
