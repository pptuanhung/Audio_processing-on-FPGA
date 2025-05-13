module equalizer (
input logic clk,
    input logic rst,
    input logic [23 :0] sam_in,
    input logic [2:0] choose [2:0],
    output logic   [23 :0] data_out);

// wire
logic [23:0] data_bass;
logic [23:0] data_mid;
logic [23:0] data_treb;
logic [23:0] data_bassmid;

bass bass (.clk(clk),
                    .rst(rst),
                    .sam_in(sam_in),
                    .choose(choose[0]),
                    .data_out(data_bass));
                    
                    
mid mid (.clk(clk),
                    .rst(rst),
                    .sam_in(sam_in),
                    .choose(choose[1]),
                    .data_out(data_mid));
treble treb(.clk(clk),
                    .rst(rst),
                    .sam_in(sam_in),
                    .choose(choose[2]),
                    .data_out(data_treb));
add_eq  add_eq1 (.a(data_bass),
                         .b(data_mid),
                         .result(data_bassmid));
add_eq  add_eq2 (.a(data_bassmid),
                         .b(data_treb),
                         .result(data_out));
endmodule
                    