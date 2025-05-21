module register #(parameter WIDTH=32)
 (input   logic rst,
//  input   logic set,
  input   logic en,
  input   logic clk,    
  input   logic [WIDTH-1:0] D,
  output  logic [WIDTH-1:0] Q);

  always_ff @(posedge clk or negedge rst ) begin  
      if (rst)
        Q <= 0;
  //   else if (set)
  //      Q <= 'hFF;
      else if (en)
        Q <= D;
    end
endmodule


