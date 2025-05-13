module lut_mem
# ( 
    parameter int ADDR_WD = 8,
    parameter int      WD = 24
  )
  (
    input  logic  [ ADDR_WD-1:0] addr_i,
    output logic  [      WD-1:0] data_o
  );
  
  reg [WD-1:0] mem [2**ADDR_WD-1:0];
  
  initial $readmemh("G:/fir/matlab/lut_output.mem",mem);
  
  assign data_o = mem[addr_i];
  
endmodule

