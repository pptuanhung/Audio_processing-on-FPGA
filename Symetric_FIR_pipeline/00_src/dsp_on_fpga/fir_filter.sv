/*module fir_filter 
 #( parameter int WD, N_TAP )
(
  input  logic                 clk_i,
  input  logic                 en_i,
  input  logic                 rst_ni,
  input  logic  [WD-1:0]  IN,
  output logic  [WD-1:0]  OUT
);
  logic   [WD-1:0] H   [N_TAP:0];
  logic [2*WD-1:0] M   [N_TAP:0];
  logic   [WD-1:0] D   [N_TAP:0];
  logic [2*WD-1:0] SD  [N_TAP -1:0];
  logic [2*WD-1:0] A   [N_TAP:0];
  logic [2*WD-1:0] S   [N_TAP:0];
  
   cof_regs  #(.WD(WD), .N_TAP(N_TAP)) COFF (.h( H ));
  
  genvar i;
  generate
      for (i = 0; i < N_TAP + 1 ; i = i + 1) begin : DELAY
        fir_delay  #(.WD(WD))  D  (
                                     .clk_i ( clk_i  ),
                                     .en_i  (  en_i  ),
                                     .rst_ni( rst_ni ),
                                     .in    ( IN     ),
                                     .out   ( D[i]  ));
      end
  endgenerate
  generate
      for (i = 0; i < N_TAP + 1 ; i = i + 1) begin : MULTIPLIER
        fir_mul  #(.WD(WD) )  MUL  (
                                     .A(   D[i] ),
                                     .B(   H[i] ),
                                     .P( M[i]  ));
      end
  endgenerate
  generate
      for (i = 0; i < N_TAP + 1 ; i = i + 1) begin : DELAY_1
        fir_delay  #(.WD(2*WD))  D  (
                                     .clk_i ( clk_i  ),
                                     .en_i  (  en_i  ),
                                     .rst_ni( rst_ni ),
                                     .in    ( M[i]   ),
                                     .out   ( A[i] ));
      end
  endgenerate
  generate
      for (i = 0; i < N_TAP  ; i = i + 1) begin : DELAY_2
        fir_delay  #(.WD(2*WD))  D  (
                                     .clk_i ( clk_i  ),
                                     .en_i  (  en_i  ),
                                     .rst_ni( rst_ni ),
                                     .in    ( S[i+1]   ),
                                     .out   ( SD[i] ));
      end
  endgenerate
  generate
      for (i = N_TAP - 1 ; i >= 0 ; i = i - 1) begin : ADDER
        fir_add  #(.WD(2*WD))  ADD  (
                                     .A      ( A [i] ),
                                     .B      ( SD[i]  ),
                                     .S      ( S [i] ));
      end
  endgenerate
 assign OUT = S [0][WD+22-1:22];
 assign S[N_TAP] = A [N_TAP];
 
  
endmodule*/




module fir_filter 
 #( parameter int WD, N_TAP )
  (
    input  logic          clk_i,
    input  logic          en_i,
    input  logic          rst_ni,
  
    input  logic [WD-1:0] IN,
  
    output logic [WD-1:0] OUT
  );

  logic   [WD-1:0] H   [N_TAP:0]; 
  logic   [WD-1:0] X   [N_TAP:0];   // input
  logic [2*WD-1:0] mul [N_TAP:0];
  logic [2*WD-1:0] sum [N_TAP:0];
  
  cof_regs  #(.WD(WD), .N_TAP(N_TAP)) COFF (.h( H ));
  
  genvar i;
  generate
      for (i = 0; i < N_TAP ; i = i + 1) begin : DELAY
        fir_delay  #(.WD(WD))  D  (
                                     .clk_i ( clk_i  ),
                                     .en_i  (  en_i  ),
                                     .rst_ni( rst_ni ),
                                     .in    ( X[i]   ),
                                     .out   ( X[i+1] ));
      end
  endgenerate
  
  generate
      for (i = 0; i < N_TAP + 1 ; i = i + 1) begin : MULTIPLIER
        fir_mul  #(.WD(WD), .N_TAP(N_TAP))  MUL  (
                                     .A(   X[i] ),
                                     .B(   H[i] ),
                                     .P( mul[i] ));
      end
  endgenerate
  
  
  generate
      for (i = N_TAP ; i > 0 ; i = i - 1) begin : ADDER
        fir_add  #(.WD(2*WD))  ADD  (
                                     .A      ( mul[i-1] ),
                                     .B      ( sum[i]   ),
                                     .S      ( sum[i-1] ));
      end
  endgenerate
  
  assign  sum[N_TAP] = mul[N_TAP];
  assign  X[0]  = IN ;
  assign  OUT   = sum[0][WD-1+22:22];
  
  logic [2*WD-1:0] sum_debug;
  assign sum_debug  = sum[0];
  
endmodule
