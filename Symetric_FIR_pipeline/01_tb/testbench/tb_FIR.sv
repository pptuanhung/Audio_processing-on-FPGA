`timescale 1ns/1ns
  
module tb_FIR ();
  
  localparam FILE_PATH = "G:/fir/samples/mems/sine.hex";
  localparam OUT_PATH  = "G:/fir/samples/mems/sine_out.hex";
  localparam FREQ = 100_000_000;
  
 

  localparam PERIOD      = 1_000_000_000/FREQ;
  localparam HALF_PERIOD = PERIOD/2          ;

  // Testbench signals
  logic               clk, reset_n;
  logic  [23:0] data_in ;
  logic [23:0] data_out;
  
  integer file, status, outfile;

  real analog_in, analog_out;
  assign analog_in  = $itor($signed(data_in));
  assign analog_out = $itor($signed(data_out));

  // Instantiate the FIR filter module
  fir  /*#(.WD(WD), .N_TAP(N_TAP))*/  dut (
                                              .clk ( clk      ),
                                              .rst ( reset_n  ),
                                              .sam_in     ( data_in  ),
                                              .data_out   ( data_out ));

  // Clock generation
  always #HALF_PERIOD clk = ~clk;

  // Test procedure
  initial begin
    // Initialize inputs
    clk     = 0;
    reset_n = 0;
    data_in = 0;

    // Apply reset
    #PERIOD reset_n = 1;  // Deassert reset after a period

    // Read hex file
    file    = $fopen(FILE_PATH,"r");
    outfile = $fopen(OUT_PATH, "w");
    if (file == 0)    $error("Hex file not opened");
    if (outfile == 0) $error("Output file not opened");
    do begin
      status = $fscanf(file, "%h", data_in);
      @(posedge clk);
      $fdisplay(outfile, "%h", data_out);
    end while ( !$feof(file) && (status == 1)) ; 

    // Wait for a while to observe output
    #2000 $stop; 
    $finish;  // Stop simulation after 100 time units
    $fclose(file);
    $fclose(outfile);
  end


endmodule