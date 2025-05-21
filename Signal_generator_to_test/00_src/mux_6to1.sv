module mux_6to1 #(
    parameter WIDTH = 5  // Data width parameter
)(
    input wire [WIDTH-1:0] in0,  // Input 0
    input wire [WIDTH-1:0] in1,  // Input 1
    input wire [WIDTH-1:0] in2,  // Input 2
    input wire [WIDTH-1:0] in3,  // Input 3
    input wire [WIDTH-1:0] in4,  // Input 4
    input wire [WIDTH-1:0] in5,  // Input 5
    input wire [2:0] sel,        // Selection signal (3-bit for 6 choices)
    output reg [WIDTH-1:0] out   // Output
);
    always @(*) begin
        case (sel)
            3'b000: out = in0;
            3'b001: out = in1;
            3'b010: out = in2;
            3'b011: out = in3;
            3'b100: out = in4;
            3'b101: out = in5;
            default: out = {WIDTH{1'b0}}; // Default value to avoid undefined states
        endcase
    end
endmodule
