module wave_gen(
    input  wire        clk,        
    input  wire        rst_n, btn0, btn1, btn2, btn3, //4 botton 
    input  wire        sw0, sw1, sw2, sw3, sw4, //5 switch
    output reg  [15:0]  wave_digital   // Output wave (16-bit wave)
);
    reg [1:0] btn_freq, noise_freq, wave_freq, wave_amp_sel, noise_amp_sel;
    reg [2:0] wave_freq_sel, noise_freq_sel;
    wire[15:0] sine_out, square_out, triangle_out, sawtooth_out, ecg_out, noise_out, noise_amp, wave_out, wave_amp ;
    wire[15:0] wave_noise, wave_noise_amp ;
    reg[15:0] wave_noise_preamp;
    wire[31:0] phase_step;  
    // reg for btn 3, btn2
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_freq <= 2'd0; 
        end else
            btn_freq <={btn3, btn2};
    end
  // demux select wave freg with sw4
   always @(*) begin
    case (sw4)
        1'b0: begin
            wave_freq  = btn_freq;
	    wave_amp_sel={btn1, btn0};   
            noise_freq = 0;
            noise_amp_sel = 0;
        end
        1'b1: begin
            wave_freq  = 0;
            noise_freq = btn_freq;
            noise_amp_sel = {btn1, btn0};  
	    wave_amp_sel=0;   
        end
    endcase
    end
  // wave_freq
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wave_freq_sel <= 3'd0; 
        end else if (wave_freq == 2'd1 ) begin
            wave_freq_sel <= wave_freq_sel - 3'd1; //dec
        end else if (wave_freq == 2'd2 ) begin
            wave_freq_sel <= wave_freq_sel + 3'd1; //inc
        end else
            wave_freq_sel <= wave_freq_sel ; 
    end
    /// mux_5to1
     mux_5to1#(.WIDTH(32)) wave_phase_step(
        .d0(32'd49),//1kHz
        .d1(32'd24),//2kHz
        .d2(32'd12),//4kHz
        .d3(32'd6),//8kHz
        .d4(32'd3),//16kHz
        .sel(wave_freq_sel),
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
   //sawtooth_wave
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
    /// mux_6to1 select wave
     mux_6to1#(.WIDTH(16)) mux_amp(
        .in0(sine_out),
        .in1(square_out),
        .in2(triangle_out),
        .in3(sawtooth_out),
        .in4(ecg_out),
        .in5(noise_amp),
        .sel({sw2, sw1, sw0}),
        .out(wave_out)
    );
    /// noise_gen
     noise_generator noise_gen(
        .clk(clk),
        .rst_n(rst_n),
        .noise_gain_inc(0),
        .noise_gain_dec(0),
        .noise_freq_inc(noise_freq[1]),
        .noise_freq_dec(noise_freq[0]),
        .noise_out(noise_out)
    );
    /// noise_amp
     Amp amp_noise(
        .clk(clk),
        .rst_n(rst_n),
        .btn0(noise_amp_sel[0]),
        .btn1(noise_amp_sel[1]),
        .wave(noise_out),
        .amp_out(noise_amp)
    );
    /// mul wave with noise
     boothmul wave_with_noise(
        .a(wave_out),
        .b(noise_amp),
        .c(wave_noise)
    );
    // mux 2 to 1 for select wave with noise or non_noise
    always @(*) begin
        case (sw3)
            1'b0: wave_noise_preamp = wave_out;
            1'b1: wave_noise_preamp = wave_noise;
            default: wave_noise_preamp = 15'b0; // Default value to avoid undefined states
        endcase
    end
    /// wave_noise amp
     Amp amp_wave_noise(
        .clk(clk),
        .rst_n(rst_n),
        .btn0(wave_amp_sel[0]),
        .btn1(wave_amp_sel[1]),
        .wave(wave_noise_preamp),
        .amp_out(wave_digital)
    );

endmodule

