module sawtooth_lut (
    input wire clk,
    input wire [9:0] phase_addr,
    output reg [15:0] sawtooth_value
);
    
    reg [15:0] sawtooth_table [0:1024];

    initial begin
        $readmemh("../00_src/Wave/Sawtooth/00_src/sawtooth_mem.dump", sawtooth_table);
    end

    always @(*) begin
        sawtooth_value = sawtooth_table[phase_addr];
    end
endmodule
