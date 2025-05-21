module ecg_lut (
    input wire clk,
    input wire [9:0] phase_addr,
    output reg [15:0] ecg_value
);
    
    reg [15:0] ecg_table [0:1024];

    initial begin
        $readmemh("../00_src/Wave/Ecg/00_src/ecg_mem.dump", ecg_table);// 
        //$readmemh("../00_src/ecg_mem.dump", ecg_table);// ../00_src/ecg_mem.dump
    end

    always @(*) begin
        ecg_value = ecg_table[phase_addr];
    end
endmodule
