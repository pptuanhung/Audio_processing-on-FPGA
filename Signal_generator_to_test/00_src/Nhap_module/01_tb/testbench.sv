module testbench;

    reg clk;
    reg rst;
    reg [23:0] freq_step;
    reg [23:0] phase_offset;
    wire signed [23:0] sin_out;
    wire signed [23:0] cos_out;
    
    // Instantiate the DDS module
    sine_generator uut (
        .clk(clk),
        .rst(rst),
        .freq_step(freq_step),
        .phase_offset(phase_offset),
        .sin_out(sin_out),
        .cos_out(cos_out)
    );
    // Enable waveform dumping
    initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    // Clock generation
    always #5 clk = ~clk; // 100MHz clock
    
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        freq_step = 24'd5000; // Set frequency step
        phase_offset = 24'd0; // No phase offset initially
        
        // Apply reset
        #20 rst = 0;
        
        // Run simulation
        #100000;
        
        // Finish
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor($time, " sin_out = %d, cos_out = %d", sin_out, cos_out);
    end
    
endmodule

