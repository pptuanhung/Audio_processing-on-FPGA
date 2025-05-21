module testbench;

	reg  clk = 1'b1;
	wire i2c_sclk;
	wire i2c_sdat;
	reg  start;
	wire done;
	wire ack;
	reg  [23:0] i2c_data;
	wire [23:0] slave_data;

	i2c_controller i2c (
	    .clk (clk),
	    .i2c_sclk (i2c_sclk),
	    .i2c_sdat (i2c_sdat),
	    .start (start),
	    .done  (done),
	    .ack   (ack),
	    .i2c_data (i2c_data)
	);

	i2c_slave slave (
	    .clk (clk),
	    .i2c_sclk (i2c_sclk),
	    .i2c_sdat (i2c_sdat),
	    .i2c_data (slave_data)
	);

   initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

     always #10 clk = !clk;//50MHz 

initial begin
    i2c_data = 24'h3a42f2;
    start = 1'b1;
    #20 start = 1'b0;

    while (!done)
        #20 assert (1'b1);

    assert (ack);
    assert (slave_data == i2c_data);
end

endmodule


