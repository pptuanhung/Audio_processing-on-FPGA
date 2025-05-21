module testbench;

    wire signed [31:0] z; // 32-bit output
    reg signed [15:0] a,b; // 16-bit inputs


   boothmul uut(
		.a(a),
		.b(b),
		.c(z));
   initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    initial
	begin
	$monitor($time,"Multiplication: %d * %d = %d",a,b,z );

	// Test case 1: Positive * Positive
	a = 16'b0000000000001111; // 15
	b = 16'b0000000000001111; // 15
	#10;

	// Test case 2: Negative * Negative
	a = 16'b1111111111110000; // -16
	b = 16'b1111111111110000; // -16
	#10;

	// Test case 3: Positive * Negative
	a = 16'b0000000010010101; // 149
	b = 16'b1111111110000000; // -128
	#10;

	// Test case 4: Zero * Positive
	a = 16'b0000000000000000; // 0
	b = 16'b0000000000000111; // 7
	#10;

	// Test case 5: One * One
	a = 16'b0000000000000001; // 1
	b = 16'b0000000000000001; // 1
	#10;

	// Test case 6: Max Positive * Max Positive (approx.)
	a = 16'b0111111111111111; // 32767
	b = 16'b0111111111111111; // 32767
	#10;

	// Test case 7: Min Negative * Min Negative (approx.)
	a = 16'b1000000000000000; // -32768
	b = 16'b1000000000000000; // -32768
	#10;

	// Test case 8: Max Negative * Max Positive
	a = 16'b1000000000000000; // -32768
	b = 16'b0111111111111111; // 32767
	#10;

	$finish;
	end
endmodule
