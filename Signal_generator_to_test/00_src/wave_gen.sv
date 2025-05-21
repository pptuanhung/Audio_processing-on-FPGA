module wave_gen(
    input  wire        clk,        
    input  wire        rst_n, btn0, btn1, btn2, btn3, //4 botton 
    input  wire        sw0, sw1, sw2, sw3, sw4, //5 switch
    output reg  [15:0]  wave_digital   // Output wave (16-bit wave)
); 
   wire [31:0] phase_step;
   wire [15:0] sine_out, triangle_out, sawtooth_out, ecg_out, noise_out;
   wire [2:0] wave_sel;
   wire [1:0] amp_sel, freq_sel;
   reg  [15:0]  wave_digital_no_noise, wave_digital_noise;
   reg  [15:0]  wave_digital_no_amp, wave_digital_amp;
   wire  wave_noise_sel;
   assign wave_sel={sw2, sw1, sw0};
  // assign amp_sel={btn1, btn0};
   //assign freq_sel={btn3, btn2};
   assign wave_noise_sel=sw4;// wave =0, noise=1
  /// Debounce
// Detects rising edge of signal_i
  edge_rise_set_en Debounce_btn0 (
      .clk_i    ( clk  ),
      .signal_i ( btn0 ),
      .en_o     ( amp_sel[0] )
  );
  edge_rise_set_en Debounce_btn1 (
      .clk_i    ( clk  ),
      .signal_i ( btn1 ),
      .en_o     ( amp_sel[1] )
  );
  edge_rise_set_en Debounce_btn2 (
      .clk_i    ( clk  ),
      .signal_i ( btn2 ),
      .en_o     ( freq_sel[0] )
  );
  edge_rise_set_en Debounce_btn3 (
      .clk_i    ( clk  ),
      .signal_i ( btn3 ),
      .en_o     ( freq_sel[1] )
  );

  /// mux_5to1 for select freg
     mux_5to1#(.WIDTH(32)) wave_phase_step(
        .d0(32'd49),//1kHz
        .d1(32'd24),//2kHz
        .d2(32'd12),//4kHz
        .d3(32'd6),//8kHz
        .d4(32'd3),//16kHz
        .sel(3'd0),//wave_freq_sel
        .y(phase_step)
    );

  //sine
    sine_wave sine_wv(
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .sine_out(sine_out)
    );
  //square_wave
    square_wave square_wv(
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .square_out(square_out)
    ); 
   //triangle_wave
    triangle_wave triangle_wv(
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .triangle_out(triangle_out)
    ); 
   //triangle_wave
    sawtooth_wave sawtooth_wv(
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .sawtooth_out(sawtooth_out)
    );
   //ecg_wave
    ecg_wave ecg_wv(
        .clk(clk),
        .rst_n(rst_n),
        .phase_step(phase_step),
        .ecg_out(ecg_out)

    );
   /// noise_gen
     noise_generator noise_gen(
        .clk(clk),
        .rst_n(rst_n),
        .noise_gain_inc(wave_noise_sel & amp_sel[1]),
        .noise_gain_dec(wave_noise_sel & amp_sel[0]),
        .noise_freq_inc(wave_noise_sel & freq_sel[1]),
        .noise_freq_dec(wave_noise_sel & freq_sel[0]),
        .noise_out(noise_out[7:0])
    );
    /// mux_6to1 select wave
     mux_6to1#(.WIDTH(16)) mux_amp(
        .in0(sine_out),
        .in1(square_out),
        .in2(triangle_out),
        .in3(sawtooth_out),
        .in4(ecg_out),
        .in5(noise_out),
        .sel(wave_sel),
        .out(wave_digital_no_noise)
    );
   // add wave with noise
     always @(*) begin 
	wave_digital_noise= wave_digital_no_noise + noise_out[7:0];
     end
   // select wave_with_noise or no noise
     always @(*) begin 
	 wave_digital_no_amp = sw3 ? wave_digital_noise : wave_digital_no_noise;
     end
    /// wave_digital_amp 
     Amp amp_wave(
        .clk(clk),
        .rst_n(rst_n),
        .btn0(~wave_noise_sel & amp_sel[0]),
        .btn1(~wave_noise_sel & amp_sel[1]),
        .wave(wave_digital_no_amp),
        .amp_out(wave_digital)
    );

endmodule

