module phase_accumulator(
    input  wire        clk,        
    input  wire        rst_n, 
    input  wire [31:0] phase_step, 
    output reg  [9:0]  phase_out   // Output phase value (10-bit)
);

    reg [31:0] counter;  // 32-bit counter

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 32'd0; 
        end else if (counter >= phase_step ) begin
            counter <= 32'd0;  // Reset counter when reaching phase_step
        end else begin
            counter <= counter + 32'd1; 
        end
    end

    // Phase accumulator logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_out <= 10'd0; // Reset phase
        end else if (counter == phase_step ) begin
            if (phase_out == 10'd1023)  // Reset when reaching max LUT index
                phase_out <= 10'd0;
            else
                phase_out <= phase_out + 10'd1;
        end
    end

endmodule

