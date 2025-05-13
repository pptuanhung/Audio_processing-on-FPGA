module cof_tre
   (
    output logic [24:0] h [50:0]
  );
  
  logic [24:0] h_temp [101:0];
  initial $readmemb("G:/wrap/matlab/treb.mem", h_temp);
  assign h = h_temp [50:0];
  
  
endmodule
