module fir_add
 # ( parameter int WD )
   (
    input  logic [WD-1:0] A,
    input  logic [WD-1:0] B,
    output logic [WD-1:0] S
   );
  
  assign S = A + B ;
  
endmodule: fir_add
