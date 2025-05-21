module mux2to1 
#(parameter int WD)
(    input logic 		[WD-1:0] ina,
     input logic 					sel,
     input logic 		[WD-1:0] inb,
     output logic		[WD-1:0] out);

assign out = (sel) ? ina : inb;

endmodule