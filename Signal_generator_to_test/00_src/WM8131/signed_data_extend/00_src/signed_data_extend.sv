module signed_data_extend
#  ( parameter int S_WD = 8, L_WD = 16 ) // Default values added// Define small and large data width
   (
    input  wire [S_WD-1:0]  data_i,    // Input data
    input  wire             signed_i,  // Mode selection: signed or unsigned extension
    output reg [L_WD-1:0]  data_o     // Output data after extension
   );

  reg [L_WD-S_WD-1:0] extend_bits;  // Extended bits

  // Determine extension bits based on signed or unsigned mode
  always @(*) begin
    if (signed_i)
      extend_bits = {L_WD-S_WD{data_i[S_WD-1]}}; // Sign extension (replicate MSB)
    else
      extend_bits = {L_WD-S_WD{1'b0}};           // Zero extension (fill with 0s)
  end

  // Concatenate extended bits with the original input data
  assign data_o = {extend_bits, data_i};

endmodule

