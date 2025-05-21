module testbench;
    // Khai báo tín hiệu
    reg  clk_i2c = 0;
    reg  reset_n = 0;
    reg  is_config;
    wire sclk;
    wire sdin;
    wire done;
    wire done_step;
    wire [23:0] i2c_data;

    // Instantiate DUT (Device Under Test)
    audio_codec uut (
        .clk_i2c  (clk_i2c),
        .reset_n  (reset_n),
        .is_config(is_config),
        .sclk     (sclk),
        .sdin     (sdin),
        .done_step(done_step),
        .done     (done)
    );

    // Declare i2c_sclk signal
    wire i2c_sclk;

    // Instantiate the i2c_slave module
    i2c_slave slave (
        .clk      (clk_i2c),
        .reset_n  (~(~reset_n | done_step)),    // Đảo tín hiệu nếu reset_n là active-low
        .i2c_sclk (sclk),
        .i2c_sdat (sdin),
        .i2c_data (i2c_data)
    );

    // Enable waveform dumping
    initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    // Clock generation
    always #10 clk_i2c = ~clk_i2c;

        // Test sequence
    initial begin

        // Initialize signals
        is_config = 0;
        reset_n = 0;

        // Apply reset
        #20 reset_n = 1;

        // Start codec configuration
        #10 is_config = 1;
        #10 is_config = 0;

        // Wait for configuration to complete
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully1.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully2.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully3.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully4.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully5.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully6.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully7.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully8.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully9.");
        wait(done);

        // Test completed
        #100;
        $display("Test completed successfully10.");
        $finish;
    end

endmodule

