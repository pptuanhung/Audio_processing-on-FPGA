module testbench;
    parameter WD = 8; // Độ rộng dữ liệu song song
  
  logic clk_i;
  logic rst_ni;
  logic en_i;
  logic shift_en;
  logic [WD-1:0] pdata_i;
  logic sdata_o;
  
  // Khởi tạo module PISO Shift Register
  piso_shift_reg #(.WD(WD)) uut (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .en_i(en_i),
    .shift_en(shift_en),
    .pdata_i(pdata_i),
    .sdata_o(sdata_o)
  );

    // Enable waveform dumping
    initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    // Clock generation
    always #10 clk_i = ~clk_i;

     initial begin
    // Khởi tạo tín hiệu
    clk_i = 0;
    rst_ni = 0;
    en_i = 0;
    shift_en = 0;
    pdata_i = 8'b11101011;  // Ví dụ dữ liệu song song

    // Reset hệ thống
    #10 rst_ni = 1;

    // Load dữ liệu song song vào shift register
    
    #10 en_i = 1;
    #20 shift_en = 0;
    #10 shift_en = 1;  // Bắt đầu shift

    // Dịch từng bit ra ngoài
    repeat (WD) begin
      #10;  // Chờ một chu kỳ clock
      $display("Time %0t: sdata_o = %b", $time, sdata_o);
    end

    // Kết thúc mô phỏng 1 
    #10 en_i = 1;
    #10 pdata_i = 8'b1010_1010;  // Ví dụ dữ liệu song song

 // Load dữ liệu song song vào shift register
    #10 shift_en = 0;
        en_i = 1;
    
    #10 shift_en = 1;  // Bắt đầu shift

    // Dịch từng bit ra ngoài
    repeat (WD) begin
      #10;  // Chờ một chu kỳ clock
      $display("Time %0t: sdata_o = %b", $time, sdata_o);
    end

    // Kết thúc mô phỏng
    #100;
    $finish;
  end

endmodule










