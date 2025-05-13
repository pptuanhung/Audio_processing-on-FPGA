module fir 
#(parameter width =24,
                tap = 101,
               cof = 24        
)
 ( input logic clk,
    input logic rst,
    input logic  signed [width -1 :0] sam_in,
    output logic signed  [width -1 :0] data_out);
    
    // arrays
    
    logic  [width-1 :0] sample [0:101];
    logic  [width  :0] pair_reg [0:50];
    logic  [24:0] result [50:0];
    logic [24:0] h [50:0];
    logic  [24:0] mul [50:0];
    


    
    // delay
    
    group_delay delay_1 (.clk (clk),
                         .rst (rst),
                         .sam_in (sam_in),
                                .sample (sample));
    // pairwise 
    pair mypair    (     .sample_in  (sample),
                            .sum_out  (pair_reg));
                            
    
    //coefficient
    
    cof_regs coeff (.h(h));            

    
    //mult 
    
    genvar k; 
    generate
     for (k = 0; k < 51; k = k +1) begin: multi_coeff
        mult mult (
            .dataa(pair_reg[k]),
            .datab(h[k]),
            .dataout(mul[k])
        ); 
    end
 endgenerate
 
 //adder 
     assign result [50] = mul[50];
                     
  genvar j;
  generate 
   for (j=49;j>=0;j= j-1) begin: add_accumulate
        adder add (.a(mul[j]),
                      .b(result[j+1]),
                      .result(result[j]));
    end
    endgenerate
    assign data_out = result[0];
    
                     
                
    
    endmodule
                
        
    