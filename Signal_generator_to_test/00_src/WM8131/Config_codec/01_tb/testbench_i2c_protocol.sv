module testbench;

    reg  clk = 1'b1;
    reg  reset_n = 1'b0;
    wire i2c_sclk;
    wire i2c_sdat;
    reg  start;
    wire done;
    wire busy;
    reg  [6:0] addr;
    reg  wr_rd;
    reg  [7:0] data_st, data_nd;
    wire [23:0] slave_data;

    // Instantiate the i2c_protocol module
    i2c_protocol i2c (
        .clk      (clk),
        .reset_n  (reset_n),
        .start    (start),
        .addr     (addr),
        .wr_rd    (wr_rd),
        .data_st  (data_st),
        .data_nd  (data_nd),
        .busy     (busy),
        .done     (done),
        .sclk     (i2c_sclk),
        .sdin     (i2c_sdat)
    );

    // Instantiate the i2c_slave module
    i2c_slave slave (
        .clk      (clk),
        .reset_n  (reset_n),
        .i2c_sclk (i2c_sclk),
        .i2c_sdat (i2c_sdat),
        .i2c_data (slave_data)
    );

    // Enable waveform dumping
    initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    // Clock generation (50 MHz)
    always #10 clk = !clk;

    // Task to perform an I2C transaction and check the result
    task i2c_test;
        input [6:0] test_addr;
        input [7:0] test_data_st, test_data_nd;
        begin
            addr    = test_addr;
            wr_rd   = 1'b0; // Write operation
            data_st = test_data_st;
            data_nd = test_data_nd;
            start   = 1'b0;reset_n = 1'b0;
            
            #20;
            
            // Start I2C transmission
            start = 1'b1;
	    reset_n = 1'b1;
            #20 start = 1'b0;

            // Wait until the operation is done
            wait(done);
            #20;
	    reset_n = 1'b0;
            #20;
	    reset_n = 1'b1;
            // Start I2C transmission
            start = 1'b1;
            #20 start = 1'b0;;
            // Wait until the operation is done
            wait(done);
            #20;

            // Check if the slave received the correct data
            $display("DEBUG DATA FROM I2C: Expected = %h, Received = %h", {test_addr, 1'b0, test_data_st, test_data_nd}, slave_data);
            assert (slave_data == {test_addr, 1'b0, test_data_st, test_data_nd})
            else $error("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Test failed: Incorrect data received by slave!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        end
    endtask

    // Test sequence
    initial begin
        $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Starting I2C Testbench.......!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

        // Test case 1
        i2c_test(7'h3A, 8'h42, 8'hF2);

        // Test case 2
        i2c_test(7'b0011010, 8'h13, 8'hFF);

        $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!All tests passed successfully!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        $finish;
    end

endmodule

