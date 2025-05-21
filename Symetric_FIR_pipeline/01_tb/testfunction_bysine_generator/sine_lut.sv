module sine_lut (
    input  logic [ 9:0] phase_addr,
    output logic [15:0] h
  );
  
  reg [15:0] h_temp [1023:0];
  initial $readmemh("G:/wrap/matlab/lut_output.mem", h_temp);
  assign h = h_temp[phase_addr];
  
  
endmodule
