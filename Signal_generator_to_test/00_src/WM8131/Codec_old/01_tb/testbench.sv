module testbench;

    reg clk = 1'b1;
    reg reset;
    wire i2c_sclk;
    wire i2c_sdat;
    wire [3:0] status;

    // Instantiate DUT (Device Under Test)
    i2c_av_config uut (
        .clk(clk),
        .reset(reset),
        .i2c_sclk(i2c_sclk),
        .i2c_sdat(i2c_sdat),
        .status(status)
    );

    // Simulating I2C Slave (WM8731)
    i2c_slave slave (
        .clk(clk),
        .i2c_sclk(i2c_sclk),
        .i2c_sdat(i2c_sdat)
    );

   initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

// Generate clock (50 MHz)
    always #10 clk = !clk;  

    // Reset system and start simulation
    initial begin
        reset = 1'b1;
       #50 reset = 1'b0;

        // Wait for all configuration to complete
        wait (status == 4'ha);

        $display("I2C Configuration Completed!");
        $finish;
    end

endmodule

