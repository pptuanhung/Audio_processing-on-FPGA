`timescale 1ns/1ps

module fifo_tb;

    // Tín hiệu cho FIFO
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [23:0] din;
    wire [23:0] dout;
    wire full;
    wire empty;

    // Gọi module FIFO
    fifo_24x128 uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Tạo xung clock 10ns (100MHz)
    always #5 clk = ~clk;

    initial begin
        // 1️⃣ Reset ban đầu
        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 24'h0;
        #20;
        rst = 0;
        #10;

        // 2️⃣ Ghi 5 mẫu dữ liệu
        repeat (5) begin
            @(posedge clk);
            wr_en = 1;
            din = din + 24'h1;
        end
        @(posedge clk);
        wr_en = 0; // Dừng ghi

        #20;

        // 3️⃣ Đọc 3 mẫu
        repeat (3) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0; // Dừng đọc

        #20;

        // 4️⃣ Ghi đến khi FIFO đầy
        while (!full) begin
            @(posedge clk);
            wr_en = 1;
            din = din + 24'h1;
        end
        @(posedge clk);
        wr_en = 0;

        // 5️⃣ Đọc đến khi FIFO rỗng
        while (!empty) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0;

        #50;
        $finish;
    end

    // Ghi log để kiểm tra trên trình mô phỏng
    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);
        $monitor("Time=%0t | wr_en=%b, rd_en=%b, din=%h, dout=%h, full=%b, empty=%b, wr_ptr=%d, rd_ptr=%d, count=%d",
                 $time, wr_en, rd_en, din, dout, full, empty, uut.wr_ptr, uut.rd_ptr, uut.count);
    end

initial begin 
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

endmodule
