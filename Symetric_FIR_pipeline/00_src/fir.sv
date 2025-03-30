module fir #(
    parameter DATA_W   = 24,  // 24-bit sample (input)
    parameter COEFF_W  = 16,  // 16-bit coefficient
    parameter TAP_FULL = 101, // Total taps
    parameter TAP_HALF = (TAP_FULL + 1)/2  // Half of TAP (for pairwise sum)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [DATA_W-1:0] sample_in,   // 24-bit input sample
    output logic signed [DATA_W-1:0] data_out  // 24-bit output data
);
   // FIFO Signals
    logic fifo_wr_en;   // Write enable for FIFO
    logic fifo_rd_en;   // Read enable for FIFO
    logic [DATA_W-1:0] fifo_dout;  // FIFO data output
    logic fifo_full, fifo_empty;

    // Instantiate the FIFO module (FIFO stores the samples)
    fifo_24x128 fifo_inst (
        .clk(clk),
        .rst(rst_n),
        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .din(sample_in),
        .dout(fifo_dout),
        .full(fifo_full),
        .empty(fifo_empty)
    );

    // Internal buffers
    logic signed [DATA_W-1:0] sample_buffer [0:TAP_FULL-1];  // Input buffer
    logic signed [DATA_W:0]   pair_sum      [0:TAP_HALF-1];  // 25-bit pair_sum
    logic signed [COEFF_W-1:0] h             [0:TAP_HALF-1] ;  // Coefficients (16-bit)
    logic signed [41:0]  product [0:TAP_HALF-1]; // 41-bit product
    logic signed [DATA_W+COEFF_W+6:0] y_full; // Full result (including some extra bits)

    // Sample shift register (FIFO-style buffer)
    integer i;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < TAP_FULL; i = i + 1)
                sample_buffer[i] <= '0;
        end else begin
            sample_buffer[0] <= sample_in;
            for (i = 1; i < TAP_FULL; i = i + 1)
                sample_buffer[i] <= sample_buffer[i-1];
        end
    end

    // Pairwise adder: Make sure pair_sum is 25-bit
    pair #(
        .WIDTH(DATA_W),  // 24-bit sample width
        .TAP(TAP_FULL)  // Total taps
    ) pair_adder (
        .sample_in(sample_buffer),
        .sum_out(pair_sum)  // 25-bit pair_sum
    );

    // Coefficient ROM: Coefficients (h) are 16-bit
    cof_mem #(
        .WIDTH(COEFF_W),
        .NUM_TAPS(TAP_HALF)
    ) rom (
        .clk(clk),
        .rst_n(rst_n),
        .data_out(h)  // Ensure no multiple connections
    );

    // Booth Multiplier Array: Multiplies 25-bit pair_sum with 16-bit h
    mult  mult_array (
        .pair_sum(pair_sum),  // 25-bit pair_sum
        .h(h),                 // Coefficients (16-bit)
        .product(product)      // 41-bit product
    );

    // CLA Adder Tree: Adds products
  cla_tree #(
        .WIDTH_IN(DATA_W + COEFF_W),
        .NUM_INPUT(TAP_HALF)
    ) adder_tree (
        .clk(clk),
        .rst_n(rst_n),
        .product(product),
        .y_out(y_full)
    );

    // Output logic: truncate 24 MSBs for final result
    assign data_out = y_full[DATA_W+COEFF_W+6 -: DATA_W];  // 24 MSBs of the result

// FIFO Control Logic (wr_en and rd_en)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_wr_en <= 0;
            fifo_rd_en <= 0;
        end else begin
            // Write data into FIFO when there is a new sample_in
            fifo_wr_en <= 1;
            if (!fifo_full) begin
                fifo_rd_en <= 1;  // Read data from FIFO for FIR to process
            end else begin
                fifo_rd_en <= 0;
            end
        end
    end


endmodule
