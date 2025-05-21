module Amp(
    input  wire        clk,        
    input  wire        rst_n, btn0, btn1, 
    input  wire [15:0]  wave, 
    output reg  [31:0]  amp_out   // Output phase value (32-bit wave)
);

    reg btn0_reg, btn1_reg;  // 32-bit counter
    reg [1:0] btn;
    assign btn= {btn1_reg, btn0_reg}; // btn1 to inc, btn0 to dec
    reg [2:0] amp_sel;
    wire [4:0] mul_const;
    // btn_reg
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn0_reg <= 1'd0; 
            btn1_reg <= 1'd0; 
        end else begin
            btn0_reg <= btn0; 
            btn1_reg <= btn1; 
        end
    end

    // Amp_sel
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            amp_sel <= 3'd0; 
        end else if (btn == 2'd1 ) begin
            amp_sel <= amp_sel - 3'd1; //dec
        end else if (btn == 2'd2 ) begin
            amp_sel <= amp_sel + 3'd1; //inc
        end else
            amp_sel <= amp_sel ; 
    end
    /// mux_5to1
     mux_5to1 #(.WIDTH(5))  mux_amp(
        .d0(5'd1),
        .d1(5'd2),
        .d2(5'd4),
        .d3(5'd6),
        .d4(5'd8),
        .sel(amp_sel),
        .y(mul_const)
    );
    /// mul_amp
     boothmul mul_amp(
        .a(wave),
        .b({11'b0,mul_const}),
        .c(amp_out)
    );

endmodule

