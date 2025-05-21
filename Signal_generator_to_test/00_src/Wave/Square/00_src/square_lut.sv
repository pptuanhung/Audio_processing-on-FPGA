module square_lut (
    input wire clk,
    input wire [9:0] phase_addr,
    output reg [15:0] square_value
);
    
    reg [15:0] square_table [0:1024];

    initial begin
        $readmemh("../00_src/Wave/Square/00_src/square_mem.dump", square_table);
    end

    always @(*) begin
        square_value = square_table[phase_addr];
    end
endmodule
