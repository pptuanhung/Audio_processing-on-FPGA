module fifo_24x128 (
    input wire clk, 
    input wire rst, 
    input wire wr_en, 
    input wire rd_en, 
    input wire [23:0] din, 
    output reg [23:0] dout, 
    output reg full, 
    output reg empty
);
    reg [23:0] mem [127:0];  // Bộ nhớ FIFO (24-bit x 128)
    reg [6:0] wr_ptr = 0;    // Con trỏ ghi (7-bit cho 128 địa chỉ)
    reg [6:0] rd_ptr = 0;    // Con trỏ đọc
    reg [7:0] count = 0;     // Bộ đếm phần tử trong FIFO

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            full   <= 0;
            empty  <= 1;
        end else begin
            // Ghi dữ liệu vào FIFO
            if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
                count  <= count + 1;
            end
            
            // Đọc dữ liệu từ FIFO
            if (rd_en && !empty) begin
                dout   <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count  <= count - 1;
            end
            
            // Cập nhật trạng thái full và empty
            full  <= (count == 128);
            empty <= (count == 0);
        end
    end
endmodule
