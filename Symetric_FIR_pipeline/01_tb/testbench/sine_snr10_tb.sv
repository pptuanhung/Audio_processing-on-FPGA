module fir_test;

  // Parameters
  parameter DATA_W   = 24;
  parameter COEFF_W  = 16;
  parameter TAP_FULL = 101;
  parameter TAP_HALF = (TAP_FULL + 1)/2;
  parameter CLK_PERIOD = 20; // 50 MHz clock
  parameter integer SAMPLES = 1024;

  real pi = 3.1415926;
  real signal_freq = 1000;  // Hz
  real fs = 50000.0;        // Hz
  real snr_db = 10.0;

  // Data memory
  logic signed [15:0] input_signal     [0:SAMPLES-1];
  logic signed [15:0] filtered_output  [0:SAMPLES-1];

  // Signals
  logic clk, rst_n;
  logic signed [15:0] sample_in;
  logic signed [15:0] data_out;

  // Clock
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // DUT
  fir_fifo #(
    .DATA_W(DATA_W),
    .COEFF_W(COEFF_W),
    .TAP_FULL(TAP_FULL),
    .TAP_HALF(TAP_HALF)
  ) fir_inst (
    .clk(clk),
    .rst_n(rst_n),
    .sample_in(sample_in),
    .data_out(data_out)
  );

  // Real to fixed-point (Q1.15)
  function automatic logic signed [15:0] real_to_fixed(input real x);
    return $rtoi(x * 32767.0);
  endfunction

  // Generate sin + noise
  task generate_signal();
    real signal_power, noise_power, noise_std;
    real sine, noise, combined;
    integer i;
    signal_power = 0.5;
    noise_power  = signal_power / (10.0 ** (snr_db / 10.0));
    noise_std    = $sqrt(noise_power);
    for (i = 0; i < SAMPLES; i++) begin
      sine = $sin(2.0 * pi * signal_freq * i / fs);
      noise = noise_std * (2.0 * $urandom_range(0, 10000)/10000.0 - 1.0);
      combined = sine + noise;
      input_signal[i] = real_to_fixed(combined);
    end
  endtask

  // Main stimulus
  initial begin
    integer i;
    integer f1, f2;

    $display("Simulation started.");
    rst_n = 0;
    sample_in = 0;

    generate_signal();

    repeat (5) @(posedge clk);
    rst_n = 1;

    // Send input
    for (i = 0; i < SAMPLES; i++) begin
      @(posedge clk);
      sample_in <= input_signal[i];
    end

    // Wait for pipeline latency (max TAP_FULL cycles)
    repeat (TAP_FULL) @(posedge clk);

    // Capture output
    for (i = 0; i < SAMPLES; i++) begin
      @(posedge clk);
      filtered_output[i] = data_out;
    end

    // Write results
    f1 = $fopen("input_signal.txt", "w");
    f2 = $fopen("filtered_output.txt", "w");
    for (i = 0; i < SAMPLES; i++) begin
      $fwrite(f1, "%d\n", input_signal[i]);
      $fwrite(f2, "%d\n", filtered_output[i]);
    end
    $fclose(f1);
    $fclose(f2);

    $display("Simulation finished.");
    $finish;
  end

  // Dump waveform
  initial begin
    $shm_open("waves.shm");
    $shm_probe("ASM");
  end

endmodule
