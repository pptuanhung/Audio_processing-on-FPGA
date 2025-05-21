module triangle_lut (
    input wire clk,
    input wire [9:0] phase_addr,
    output reg [15:0] triangle_value
);
    
    reg [15:0] triangle_table [0:1024];

    initial begin
        $readmemh("../00_src/Wave/Triangle/00_src/triangle_mem.dump", triangle_table);
    end

    always @(*) begin
        triangle_value = triangle_table[phase_addr];
    end
endmodule
