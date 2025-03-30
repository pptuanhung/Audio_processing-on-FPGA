module mult_array_tb;

    // Parameters
    parameter DATA_W  = 25;   // 25-bit for pair_sum
    parameter COEFF_W = 16;   // 16-bit for coefficients (h)
    parameter TAP      = 4;   // Number of multipliers (you can adjust TAP for more tests)

    // Signals
    logic signed [DATA_W-1:0]  pair_sum [0:TAP-1];  // 25-bit pair_sum array
    logic signed [COEFF_W-1:0] h        [0:TAP-1];  // 16-bit coefficients array
    logic signed [DATA_W+COEFF_W-1:0] product [0:TAP-1];  // 41-bit product array

    // Instantiate the mult_array module
    mult_array #(
        .DATA_W(DATA_W),
        .COEFF_W(COEFF_W),
        .TAP(TAP)
    ) mult_array_inst (
        .pair_sum(pair_sum),
        .h(h),
        .product(product)
    );

    // Test procedure
    initial begin
        // Initialize signals
        $display("Starting mult_array testbench...");
        
        // Assign values to pair_sum and h (Example values for testing)
        pair_sum[0] = 25'b0000000000000000000000001;  // 1 in 25-bit
        pair_sum[1] = 25'b0000000000000000000000010;  // 2 in 25-bit
        pair_sum[2] = 25'b0000000000000000000000100;  // 4 in 25-bit
        pair_sum[3] = 25'b0000000000000000000001000;  // 8 in 25-bit

        h[0] = 16'b0000000000000011;  // 3 in 16-bit
        h[1] = 16'b0000000000000101;  // 5 in 16-bit
        h[2] = 16'b0000000000000111;  // 7 in 16-bit
        h[3] = 16'b0000000000001001;  // 9 in 16-bit

        // Apply stimulus and check results
        #10;  // Wait for the results to settle

        // Display product results
        $display("Results:");
        for (int i = 0; i < TAP; i = i + 1) begin
            $display("product[%0d] = %d", i, product[i]);
        end

        // Test Case 2: Test with random values
        $display("Test 2: Random values");
        pair_sum[0] = 25'b0000000000000000000011111;  // Random 25-bit
        pair_sum[1] = 25'b0000000000000000000101010;  // Random 25-bit
        pair_sum[2] = 25'b0000000000000000000110000;  // Random 25-bit
        pair_sum[3] = 25'b0000000000000000001000101;  // Random 25-bit

        h[0] = 16'b0000000000001111;  // Random 16-bit
        h[1] = 16'b0000000000011011;  // Random 16-bit
        h[2] = 16'b0000000000100101;  // Random 16-bit
        h[3] = 16'b0000000000110001;  // Random 16-bit

        #10;  // Wait for the results

        // Display updated product results
        $display("Updated Results:");
        for (int i = 0; i < TAP; i = i + 1) begin
            $display("product[%0d] = %d", i, product[i]);
        end

        // End the simulation
        $finish;
    end

endmodule
