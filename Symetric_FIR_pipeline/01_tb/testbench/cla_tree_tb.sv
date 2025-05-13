`timescale 1ns/1ps

module cla_tree_tb;

    parameter WIDTH_IN  = 40;
    parameter NUM_INPUT = 51;
    parameter PIPE_DEPTH = 6;

    // Clock & reset
    logic clk;
    logic rst_n;

    // DUT signals
    logic signed [WIDTH_IN-1:0] product [0:NUM_INPUT-1];
    logic signed [WIDTH_IN+6:0] y_out;

    // Instantiate DUT
cla_tree#(
        .WIDTH_IN(WIDTH_IN),
        .NUM_INPUT(NUM_INPUT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .product(product),
        .y_out(y_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Input data
    integer i;
    logic signed [WIDTH_IN-1:0] input_data [0:NUM_INPUT-1];
    logic signed [WIDTH_IN+6:0] expected_sum;

    initial begin
        // Init
        clk = 0;
        rst_n = 0;
        #12;
        rst_n = 1;

        // Generate test input: product[i] = i + 1
        expected_sum = 0;
        for (i = 0; i < NUM_INPUT; i = i + 1) begin
            input_data[i] = i + 1;
            expected_sum += input_data[i];
        end

        // Apply inputs
        for (i = 0; i < NUM_INPUT; i = i + 1)
            product[i] = input_data[i];

        // Wait for pipeline delay
        repeat (PIPE_DEPTH + 2) @(posedge clk);

        // Check result
        $display("Expected sum = %0d", expected_sum);
        $display("Output y_out = %0d", y_out);

        if (y_out === expected_sum)
            $display("✅ TEST PASSED!");
        else
            $display("❌ TEST FAILED!");

        $finish;
    end
initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

endmodule
