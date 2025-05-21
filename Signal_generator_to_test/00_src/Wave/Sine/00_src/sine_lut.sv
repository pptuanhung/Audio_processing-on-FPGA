module sine_lut (
    input wire clk,
    input wire [9:0] phase_addr,
    output reg [15:0] sine_value
);
    
    reg [15:0] sine_table [0:1024];

    initial begin
        $readmemh("../00_src/Wave/Sine/00_src/sine_mem.dump", sine_table);// if only test in folder sine wave please adjust path
    end

    always @(*) begin
        sine_value = sine_table[phase_addr];
    end
endmodule
