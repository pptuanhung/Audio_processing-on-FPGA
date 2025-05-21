module signed_data_extend
#  ( parameter int S_WD, L_WD ) // small or large data-width
   (
    input  logic [S_WD-1:0]  data_i,
    input  logic             signed_i,
    output logic [L_WD-1:0]  data_o
   );

  logic [L_WD-1:S_WD]   s_data_ex;  //   signed extend
  logic [L_WD-1:S_WD]  us_data_ex;  // unsigned extend
  logic [L_WD-1:S_WD]     data_ex;  //          extend selected by signed_i

  always_comb begin
    for (int i=S_WD; i<L_WD ; i++ ) begin
       us_data_ex[i] =         1'b0;
        s_data_ex[i] = data_i[S_WD-1];
    end
  end
  
  assign data_ex = ( signed_i ) ? s_data_ex : us_data_ex ;
  assign data_o  = {data_ex, data_i};
  
endmodule

