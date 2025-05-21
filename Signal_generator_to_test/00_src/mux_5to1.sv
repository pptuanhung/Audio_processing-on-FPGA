module mux_5to1 #(
    parameter WIDTH = 8  // Độ rộng của dữ liệu
)(
    input wire [2:0] sel,                // Tín hiệu chọn (3 bit đủ để chọn 5 đầu vào)
    input wire [WIDTH-1:0] d0, d1, d2, d3, d4, // 5 tín hiệu đầu vào
    output reg [WIDTH-1:0] y             // Đầu ra đã được đăng ký (register)
);

  always @(*) begin
      case (sel)
          3'b000: y = d0;
          3'b001: y = d1;
          3'b010: y = d2;
          3'b011: y = d3;
          3'b100: y = d4;
          default: y = d0;  // Tránh trạng thái không xác định
      endcase
  end

endmodule

