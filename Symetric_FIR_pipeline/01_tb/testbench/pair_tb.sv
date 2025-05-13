`timescale 1ns/1ps

module pairwise_adder_tb;

    parameter WIDTH = 24;
    parameter TAP   = 101;

    // DUT I/O
    logic signed [WIDTH-1:0] sample_in [0:TAP-1];
    logic signed [WIDTH:0]   sum_out   [0:(TAP-1)/2];

    // Instantiate DUT
pair #(
        .WIDTH(WIDTH),
        .TAP(TAP)
    ) dut (
        .sample_in(sample_in),
        .sum_out(sum_out)
    );

    // Testbench body
    integer i;

    initial begin
        $display("---- TEST PAIRWISE ADDER ----");

        // Khởi tạo mẫu: sample_in[i] = i
        for (i = 0; i < TAP; i = i + 1) begin
            sample_in[i] = i; // hoặc: sample_in[i] = $random;
        end

        #1; // Wait for combinational logic to settle

        // Hiển thị kết quả
        for (i = 0; i <= (TAP-1)/2; i = i + 1) begin
            $display("sum_out[%0d] = sample_in[%0d] + sample_in[%0d] = %0d + %0d = %0d",
                     i, i, TAP-1 - i, sample_in[i], sample_in[TAP-1 - i], sum_out[i]);
        end

        $finish;
    end
initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

endmodule
