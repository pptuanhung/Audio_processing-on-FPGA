// CLA_Adder_Tree_Pipelined.v - Dùng module adder & dff

module cla_tree #(
    parameter WIDTH_IN  = 40,
    parameter NUM_INPUT = 51
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [41:0] product [0:NUM_INPUT-1],
    output logic signed [WIDTH_IN+6:0] y_out
);

    // Layer wires
    logic signed [WIDTH_IN+0:0] layer0 [0:25];
    logic signed [WIDTH_IN+1:0] layer1 [0:12];
    logic signed [WIDTH_IN+2:0] layer2 [0:6];
    logic signed [WIDTH_IN+3:0] layer3 [0:3];
    logic signed [WIDTH_IN+4:0] layer4 [0:1];
    logic signed [WIDTH_IN+5:0] layer5;

    // Pipeline registers
    logic signed [WIDTH_IN+0:0] reg_l0 [0:25];
    logic signed [WIDTH_IN+1:0] reg_l1 [0:12];
    logic signed [WIDTH_IN+2:0] reg_l2 [0:6];
    logic signed [WIDTH_IN+3:0] reg_l3 [0:3];
    logic signed [WIDTH_IN+4:0] reg_l4 [0:1];
    logic signed [WIDTH_IN+5:0] reg_l5;

    genvar i;

    // Layer 0: 25 adders + 1 passthrough
    generate
        for (i = 0; i < 25; i = i + 1) begin : gen_l0_add
            adder #(.WIDTH(WIDTH_IN)) add0 (
                .a(product[2*i]),
                .b(product[2*i+1]),
                .sum(layer0[i])
            );
        end
    endgenerate
    assign layer0[25] = product[50];

    generate
        for (i = 0; i < 26; i = i + 1) begin : gen_l0_reg
            dff #(.WIDTH(WIDTH_IN+1)) dff0 (
                .clk(clk),
                .rst_n(rst_n),
                .d(layer0[i]),
                .q(reg_l0[i])
            );
        end
    endgenerate

    // Layer 1: 13 adders
    generate
        for (i = 0; i < 13; i = i + 1) begin : gen_l1_add
            adder #(.WIDTH(WIDTH_IN+1)) add1 (
                .a(reg_l0[2*i]),
                .b(reg_l0[2*i+1]),
                .sum(layer1[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < 13; i = i + 1) begin : gen_l1_reg
            dff #(.WIDTH(WIDTH_IN+2)) dff1 (
                .clk(clk),
                .rst_n(rst_n),
                .d(layer1[i]),
                .q(reg_l1[i])
            );
        end
    endgenerate

    // Layer 2: 6 adders + 1 passthrough
    generate
        for (i = 0; i < 6; i = i + 1) begin : gen_l2_add
            adder #(.WIDTH(WIDTH_IN+2)) add2 (
                .a(reg_l1[2*i]),
                .b(reg_l1[2*i+1]),
                .sum(layer2[i])
            );
        end
    endgenerate
    assign layer2[6] = reg_l1[12];

    generate
        for (i = 0; i < 7; i = i + 1) begin : gen_l2_reg
            dff #(.WIDTH(WIDTH_IN+3)) dff2 (
                .clk(clk),
                .rst_n(rst_n),
                .d(layer2[i]),
                .q(reg_l2[i])
            );
        end
    endgenerate

    // Layer 3: 3 adders + 1 passthrough
    generate
        for (i = 0; i < 3; i = i + 1) begin : gen_l3_add
            adder #(.WIDTH(WIDTH_IN+3)) add3 (
                .a(reg_l2[2*i]),
                .b(reg_l2[2*i+1]),
                .sum(layer3[i])
            );
        end
    endgenerate
    assign layer3[3] = reg_l2[6];

    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_l3_reg
            dff #(.WIDTH(WIDTH_IN+4)) dff3 (
                .clk(clk),
                .rst_n(rst_n),
                .d(layer3[i]),
                .q(reg_l3[i])
            );
        end
    endgenerate

    // Layer 4: 2 adders
    adder #(.WIDTH(WIDTH_IN+4)) add4_0 (
        .a(reg_l3[0]),
        .b(reg_l3[1]),
        .sum(layer4[0])
    );
    adder #(.WIDTH(WIDTH_IN+4)) add4_1 (
        .a(reg_l3[2]),
        .b(reg_l3[3]),
        .sum(layer4[1])
    );

    dff #(.WIDTH(WIDTH_IN+5)) dff4_0 (
        .clk(clk),
        .rst_n(rst_n),
        .d(layer4[0]),
        .q(reg_l4[0])
    );
    dff #(.WIDTH(WIDTH_IN+5)) dff4_1 (
        .clk(clk),
        .rst_n(rst_n),
        .d(layer4[1]),
        .q(reg_l4[1])
    );

    // Layer 5: final adder
    adder #(.WIDTH(WIDTH_IN+5)) add5 (
        .a(reg_l4[0]),
        .b(reg_l4[1]),
        .sum(layer5)
    );

    dff #(.WIDTH(WIDTH_IN+6)) dff5 (
        .clk(clk),
        .rst_n(rst_n),
        .d(layer5),
        .q(reg_l5)
    );

    assign y_out = reg_l5;

endmodule
