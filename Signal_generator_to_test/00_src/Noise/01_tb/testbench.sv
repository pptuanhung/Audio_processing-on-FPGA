module testbench;

   reg clk;
    reg rst_n;
    reg noise_gain_inc, noise_gain_dec;
    reg noise_freq_inc, noise_freq_dec;
    wire signed [23:0] noise_out;
    wire signed [23:0] analog_noise;
    real noise_scaled; // Declare real in TB

    // Instantiate DUT
    noise_generator uut (
        .clk(clk),
        .rst_n(rst_n),
        .noise_gain_inc(noise_gain_inc),
        .noise_gain_dec(noise_gain_dec),
        .noise_freq_inc(noise_freq_inc),
        .noise_freq_dec(noise_freq_dec),
        .noise_out(noise_out),
        .analog_noise(analog_noise)
    );
   initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

     // Generate clock (50MHz = 20ns period)
    always #5 clk = ~clk;

    initial begin
        // Khởi tạo tín hiệu
        clk = 0;
        rst_n = 0;
        noise_gain_inc = 0;
        noise_gain_dec = 0;
        noise_freq_inc = 0;
        noise_freq_dec = 0;

        // Reset hệ thống
        #50;
        rst_n = 1;

        // Tăng tần số nhiễu
        #250 noise_freq_inc = 1; #20 noise_freq_inc = 0;
        #251 noise_freq_inc = 1; #20 noise_freq_inc = 0;
        #250 noise_freq_inc = 1; #20 noise_freq_inc = 0;
        #250 noise_freq_inc = 1; #20 noise_freq_inc = 0;
        #250 noise_freq_inc = 1; #20 noise_freq_inc = 0;

        // Giảm tần số nhiễu
        #250 noise_freq_dec = 1; #20 noise_freq_dec = 0;

        // Tăng biên độ nhiễu
        #250 noise_gain_inc = 1; #20 noise_gain_inc = 0;
        #250 noise_gain_inc = 1; #20 noise_gain_inc = 0;
        #250 noise_gain_inc = 1; #20 noise_gain_inc = 0;
        #250 noise_gain_inc = 1; #20 noise_gain_inc = 0;

        // Giảm biên độ nhiễu
        #250 noise_gain_dec = 1; #20 noise_gain_dec = 0;

        // Quan sát giá trị nhiễu
        #500;
        
        // Kết thúc mô phỏng
        $finish;
    end

    // Monitor giá trị trong terminal
    initial begin
        $monitor("Time = %0t | noise_out = %h | freq_inc = %b | freq_dec = %b | gain_inc = %b | gain_dec = %b", 
                  $time, noise_out, noise_freq_inc, noise_freq_dec, noise_gain_inc, noise_gain_dec);
    end
    always @(analog_noise) begin
        noise_scaled = $itor(analog_noise) / (2**23);
    end
endmodule


