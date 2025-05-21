module testbench;

    reg clk = 0;
    reg rst_n = 0;
    reg btn0, btn1, btn2, btn3;
    reg sw0, sw1, sw2, sw3, sw4;
    wire [15:0] wave_digital;

    // Clock generation
    always #5 clk = ~clk; // 100MHz clock

    // Instantiate DUT
    wave_gen uut (
        .clk(clk),
        .rst_n(rst_n),
        .btn0(btn0),
        .btn1(btn1),
        .btn2(btn2),
        .btn3(btn3),
        .sw0(sw0),
        .sw1(sw1),
        .sw2(sw2),
        .sw3(sw3),
        .sw4(sw4),
        .wave_digital(wave_digital)
    );
    
   initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end
    // Clock generation (50MHz = 20ns period)
    always #10 clk = ~clk;
    
    initial begin
        // Initialize inputs
        rst_n = 0;
        btn0 = 0; btn1 = 0; btn2 = 0; btn3 = 0;
        sw0 = 0; sw1 = 0; sw2 = 0; sw3 = 0; sw4 = 0;
        #20 rst_n = 1; // Release reset
        
        // Test different wave selections
        sw2 = 0; sw1 = 0; sw0 = 0; #10000000; // Sine wave
	//sw2 = 0; sw1 = 0; sw0 = 1; #10000000; // sq wave
	//sw2 = 0; sw1 = 1; sw0 = 0; #10000000; // triang wave
// Increase noise amplitude
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150000;  
btn0 = 0; #150; btn0 = 1; #150; btn0 = 0; #150000;  

// Decrease noise amplitude
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150000;  

// Increase noise frequency
btn3 = 0; #150; btn3 = 1; #150; btn3 = 0; #150000;  

// Decrease noise frequency
btn2 = 0; #150; btn2 = 1; #150; btn2 = 0; #150000;  
// Decrease noise amplitude
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150000;  
// Decrease noise amplitude
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150000;  

	sw2 = 0; sw1 = 1; sw0 = 1; #10000000; // sawtooth_wave
// Increase noise amplitude
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150000;  
btn0 = 0; #150; btn0 = 1; #150; btn0 = 0; #150000;  
// Increase noise amplitude
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150000;  
btn0 = 0; #150; btn0 = 1; #150; btn0 = 0; #150000;  
// Increase noise amplitude
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150000;  
btn0 = 0; #150; btn0 = 1; #150; btn0 = 0; #150000; 
// Increase noise amplitude
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150; 
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150;  
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150;  
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150;  
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150;  
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150;  
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150;  
btn1 = 0; #150; btn1 = 1; #150; btn1 = 0; #150;  
	sw2 = 1; sw1 = 0; sw0 = 0; #10000000; // ecg wave
	//sw2 = 1; sw1 = 0; sw0 = 1; #10000000; // noise wave
	//sw2 = 1; sw1 = 1; sw0 = 0; #10000000; // random wave

        #10000000;
        $finish;
    end

endmodule

