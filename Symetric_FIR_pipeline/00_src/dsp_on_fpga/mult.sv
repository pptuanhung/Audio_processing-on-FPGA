module mult
(
    input logic signed [24:0] dataa,
    input logic signed[24:0] datab,
    output logic signed [24:0] dataout
    
);
    logic signed [49:0] mult;

/*   assign mult = dataa * datab;*/
   assign dataout = mult [24+23:23];
  
  
 lplp MULT_BLCK ( 
    .dataa ( dataa ),
    .datab ( datab ),
    .result( mult ));
  
  
endmodule
