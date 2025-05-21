module data_process 
(
);
//


//




//
equalizer eq_process( .clk(),
                      .rst(),
                      .sam_in(),
                      .choose,
                     . data_out);
//
 mux2to1 #(WD=24) eq_or_noeq  (.ina(),
                               .sel(),
                               .inb(),
                               .out());


endmodule