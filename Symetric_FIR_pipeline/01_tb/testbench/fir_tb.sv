module fir_tb;

    // Parameters
    parameter DATA_W   = 24;   // 24-bit sample
    parameter COEFF_W  = 16;   // 16-bit coefficient
    parameter TAP_FULL = 101;  // Total taps
    parameter TAP_HALF = (TAP_FULL + 1)/2;  // Half of TAP (for pairwise sum)

    // Signals
    logic clk;
    logic rst_n;
    logic signed [DATA_W-1:0] sample_in;  // 24-bit input sample
    logic signed [DATA_W-1:0] data_out;  // 24-bit output data

    // Instantiate the FIR module
    fir #(
        .DATA_W(DATA_W),
        .COEFF_W(COEFF_W),
        .TAP_FULL(TAP_FULL),
        .TAP_HALF(TAP_HALF)
    ) fir_inst (
        .clk(clk),
        .rst_n(rst_n),
        .sample_in(sample_in),
        .data_out(data_out)
    );

    // Clock Generation
    always begin
        #5 clk = ~clk; // Clock period = 10 units
    end

    // Initial Block for Test Sequence
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        sample_in = 0;

        // Reset FIR module
        $display("Resetting the system...");
        rst_n = 0;
        #10;
        rst_n = 1;
        #10;

        // Test Case 1: Apply input samples to FIR
        $display("Test 1: Apply input samples");
        sample_in = 24'h001000;  // Sample 1
        #10;
        sample_in = 24'h002000;  // Sample 2
        #10;
        sample_in = 24'h003000;  // Sample 3
        #10;
        sample_in = 24'h004000;  // Sample 4
        #10;
        sample_in = 24'h005000;  // Sample 5
        #10;

        // Test Case 2: Apply negative samples
        $display("Test 2: Apply negative samples");
        sample_in = 24'hFFF000;  // Negative sample
        #10;
        sample_in = 24'hFF9000;  // Negative sample
        #10;

        // Test Case 3: Apply zero sample
        $display("Test 3: Apply zero sample");
        sample_in = 24'h000000;  // Zero sample
        #10;

        // Test Case 4: Apply random values
        $display("Test 4: Apply random samples");
        sample_in = 24'h00FF00;  // Random sample
        #10;
        sample_in = 24'h123456;  // Random sample
        #10;

        // Test Case 5: Apply large positive sample
        $display("Test 5: Apply large positive sample");
        sample_in = 24'hFFFFFF;  // Maximum possible value (all bits set to 1)
        #10;

        // Test Case 6: Apply large negative sample
        $display("Test 6: Apply large negative sample");
        sample_in = 24'h800000;  // Minimum possible value (most significant bit set to 1)
        #10;

        // End the simulation
        $finish;
    end

    // Monitor output
    always @(posedge clk) begin
        $display("At time %t, data_out = %h", $time, data_out);
    end
initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

endmodule
