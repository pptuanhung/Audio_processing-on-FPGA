module noise_mux
(input logic [23:0] sine,
input logic switch,
output logic [23:0] sine_noise);

 mux2to1 #(.WD(24)) mux_noise (.ina(sine),
                              .sel(switch),
                              .inb (1'b0),
                               .out(sine_noise));

endmodule