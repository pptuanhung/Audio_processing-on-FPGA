module clk_div (
    input wire clk,          
    input wire rst, freq_inc, freq_dec,       
    output reg clk_out    
);

    // Internal signals
    reg clk_div2, clk_div4, clk_div8, clk_div16;
    reg [2:0] count;

    // Frequency control counter
    always @(posedge clk) begin
        if (rst) begin
            count <= 3'b000; // Reset to 0
        end else begin
            case ({freq_inc, freq_dec})
                2'b10: if (count < 3'd4) count <= count + 1; // Increase if below 4
                2'b01: if (count > 3'd0) count <= count - 1; // Decrease if above 0
                default: count <= count; // Hold value if no change
            endcase
        end
    end

    // Clock divider chain
    always @(posedge clk or posedge rst) begin
        if (rst)
            clk_div2 <= 0;
        else
            clk_div2 <= ~clk_div2;
    end

    always @(posedge clk_div2 or posedge rst) begin
        if (rst)
            clk_div4 <= 0;
        else
            clk_div4 <= ~clk_div4;
    end

    always @(posedge clk_div4 or posedge rst) begin
        if (rst)
            clk_div8 <= 0;
        else
            clk_div8 <= ~clk_div8;
    end

    always @(posedge clk_div8 or posedge rst) begin
        if (rst)
            clk_div16 <= 0;
        else
            clk_div16 <= ~clk_div16;
    end

    // MUX selects output clock based on count value
    mux_5to1 #(1) mux_clk (
        .sel(count),
        .d0(clk_div16),
        .d1(clk_div8),
        .d2(clk_div4),
        .d3(clk_div2),
        .d4(clk),
        .y(clk_out)
    );

endmodule

