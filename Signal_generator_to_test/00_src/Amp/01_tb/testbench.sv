module testbench;

    reg clk;
    reg rst_n;
    reg btn0, btn1;
    reg [15:0] wave;
    wire [15:0] amp_out;
    
    // Instantiate DUT (Device Under Test)
    Amp uut (
        .clk(clk),
        .rst_n(rst_n),
        .btn0(btn0),
        .btn1(btn1),
        .wave(wave),
        .amp_out(amp_out)
    );
    initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        btn0 = 0;
        btn1 = 0;
        wave = 16'd100;
        
    // Clock generation (50MHz = 20ns period)
    always #10 clk = ~clk;
        
        // Test increasing amplitude
        #20 btn1 = 1; #10 btn1 = 0;
        #20 btn1 = 1; #10 btn1 = 0;
        
        // Test decreasing amplitude
        #20 btn0 = 1; #10 btn0 = 0;
        
        // Apply wave change
        #30 wave = 16'd200;
        
        // Additional test cases
        #50 btn1 = 1; #10 btn1 = 0;
        #20 btn0 = 1; #10 btn0 = 0;
        
        // Finish simulation
        #100 $finish;
    end
    
    // Monitor output
    initial begin
        $monitor("Time=%0t, wave=%d, amp_out=%d, btn0=%b, btn1=%b", $time, wave, amp_out, btn0, btn1);
    end
endmodule

