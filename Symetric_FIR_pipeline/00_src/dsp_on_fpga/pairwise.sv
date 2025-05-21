module pair 
(
    input  logic  [23:0] sample_in [0:101],   
    output logic  [24:0]   sum_out   [0:50]  );


    genvar i;
    generate
        for (i = 0; i <= 50; i = i + 1) begin : gen_pair_add
            
            //assign sum_out[i] = sample_in[i] + sample_in[101 - i];
            add_sample add (.dataa(sample_in[i]), .datab(sample_in[ 101-i]), .dataout(sum_out[i]));
        end
    endgenerate

endmodule

///////////////////////////////////////////////////////////////////////////
module add_sample
(
    input logic signed [23:0] dataa,
    input logic signed [23:0] datab,
    output logic signed [24:0] dataout
    
);

    assign dataout = dataa + datab;

endmodule
