module sine_mem
# ( 
    parameter int ADDR_WD = 8,
    parameter int      WD = 16
  )
  (
    input  logic  [ ADDR_WD-1:0] addr_i,
    output logic  [      WD-1:0] data_o
  );
  
  reg [WD-1:0] mem [2**ADDR_WD-1:0];
  
  initial $readmemh("matlab/sine_wave_16b.hex",mem);
  
  assign data_o = mem[addr_i];
  
endmodule

