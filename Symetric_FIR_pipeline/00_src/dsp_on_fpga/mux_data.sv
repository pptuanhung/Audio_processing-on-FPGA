module data_mux
(input logic [23:0] datain,
input logic switch,
output logic [23:0] dataout);

 mux2to1 #(WD(24)) mux_noise (.ina(datain),
                              .sel(switch),
                              .inb (1'b0),
                               .out(dataout));

endmodule