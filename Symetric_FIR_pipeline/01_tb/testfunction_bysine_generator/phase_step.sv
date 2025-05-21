module phase_accumulator(
    input wire clk,         
    input wire rst_n,       
    output reg [9:0] phase_out  
);

    reg [31:0] counter;    

    localparam phase_temp = 204;  

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 32'd0; 
        end else if (counter >= phase_temp) begin
            counter <= 32'd0;  
        end else begin
            counter <= counter + 32'd1; 
        end
    end

  
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_out <= 10'd0; 
        end else if (counter == phase_temp) begin
            if (phase_out == 10'd1023)  
                phase_out <= 10'd0;
            else
                phase_out <= phase_out + 10'd1;  
        end
    end

endmodule
