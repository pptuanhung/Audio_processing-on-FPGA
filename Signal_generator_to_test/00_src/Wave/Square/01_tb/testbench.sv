module testbench;

    reg clk;
    reg rst_n;
    reg [31:0] phase_step; 
    wire  square_out;

    // Instantiate the square wave generator
    square_wave uut (
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .square_out(square_out)
    );
   initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    // Clock generation (50MHz = 20ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;

        // Apply reset
        #11 rst_n = 1;
	
	phase_step=12;
        // Run simulation
        #10000000;
	
	phase_step=3;
	
        #10000000;
        // Finish simulation
        $finish;
    end

    /* Monitor output
    initial begin
        $monitor("%0t: square_out = %d", $time, square_out);
    end*/

endmodule

