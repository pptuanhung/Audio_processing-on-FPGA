`timescale 1ns / 1ps

module testbench;
    // Testbench signals
    reg clk_i;
    reg signal_i;
    reg rst_n;
    wire en_o;

    // Instantiate the DUT (Device Under Test)
    toggle_on_edge_rise dut (
        .clk_i    ( clk_i    ),
        .signal_i ( signal_i ),
        .rst_n    ( rst_n    ),
        .en_o     ( en_o     )
    );

    // Enable waveform dumping for simulation
    initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    // Clock generation (50MHz => 20ns period)
    always #10 clk_i = ~clk_i;

    // Test Procedure
    initial begin
        // Initialize signals
        clk_i = 0;
        rst_n = 0;
        signal_i = 0;
        #50;  // Hold reset for some time

        // Release reset
        rst_n = 1;
        #50;

        // Apply signal_i pulses
        signal_i = 1; #140;  // Rising edge: toggle en_o
        signal_i = 0; #45;
        signal_i = 1; #44;  // Rising edge: toggle en_o again
        signal_i = 0; #45;
        signal_i = 1; #46;  // Another rising edge
        signal_i = 0; #40;
        
        // Assert reset
        rst_n = 0; #55;
        rst_n = 1; #150;

        // More toggling tests
        signal_i = 1; #40;
        signal_i = 0; #40;
        signal_i = 1; #40;
        signal_i = 0; #40;

        // End simulation
        $finish;
    end
endmodule

