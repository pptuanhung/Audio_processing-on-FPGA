module data_in 
( input logic rst_ni,
  input logic [1:0] SW,
  input logic clk_i
  
  );
//



//  
  sine_gen    sine_highf (.clk_i(),
                       .rst_ni(),
  
                       .wave_o()
  );
//
noise_mux    sine_noise (.sine(),
                      .switch(),
                      .sine_noise());
//
audio line in



//
data_mux    data_line_in ( .datain(),
                        .switch(),
                        .dataout());
//
add_noise    add_noise_data_line_in (.a(),
                                     .b(),
                                     .result(data_in));

endmodule
