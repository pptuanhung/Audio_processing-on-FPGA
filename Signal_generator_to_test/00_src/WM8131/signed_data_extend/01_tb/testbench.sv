module testbench;
    // Parameters
  parameter int S_WD = 8;  // Small width (input width)
  parameter int L_WD = 16; // Large width (output width)

  // Test signals
  reg [S_WD-1:0] data_i;   // Input data
  reg signed_i;            // Signed/Unsigned mode selection
  wire [L_WD-1:0] data_o;  // Output data after extension

  // Instantiate DUT (Device Under Test)
  signed_data_extend #(.S_WD(S_WD), .L_WD(L_WD)) DUT (
    .data_i(data_i),
    .signed_i(signed_i),
    .data_o(data_o)
  );

    // Enable waveform dumping
    initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    // Test procedure
  initial begin
    // Test Case 1: Unsigned extension
    signed_i = 0;
    data_i = 8'b00001111; // 15 in decimal
    #10;
    $display("Unsigned: Input = %b, Output = %b", data_i, data_o);
    
    // Test Case 2: Unsigned extension (higher value)
    data_i = 8'b10001111; // 143 in decimal
    #10;
    $display("Unsigned: Input = %b, Output = %b", data_i, data_o);

    // Test Case 3: Signed extension (positive number)
    signed_i = 1;
    data_i = 8'b00001111; // 15 in decimal
    #10;
    $display("Signed: Input = %b, Output = %b", data_i, data_o);

    // Test Case 4: Signed extension (negative number)
    data_i = 8'b10001111; // -113 in signed 8-bit representation
    #10;
    $display("Signed: Input = %b, Output = %b", data_i, data_o);

    // End of simulation
    $finish;
  end
endmodule







