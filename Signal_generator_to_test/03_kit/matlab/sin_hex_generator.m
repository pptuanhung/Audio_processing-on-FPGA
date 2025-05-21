% Thông số
A = (2^9) - 1;  % Biên độ số nguyên (15-bit do 16-bit có bit dấu)
f = 50;          % Tần số (Hz)
N = 1024;         % Số mẫu trong một chu kỳ
B = 10;          % Độ dài bit (16-bit bù 2)

% Tạo N mẫu trong 1 chu kỳ
T = 1 / f;                      % Chu kỳ
t = linspace(0, T, N);          % Lấy N điểm đều nhau
x = A * sin(2 * pi * f * t);    % Sóng sine với biên độ số nguyên

% Chuyển về số nguyên có dấu (bù 2)
x_int = round(x);               % Làm tròn thành số nguyên
x_int(x_int >= 2^(B-1)) = 2^(B-1) - 1;  % Giới hạn giá trị max
x_int(x_int < -2^(B-1)) = -2^(B-1);     % Giới hạn giá trị min

% Chuyển sang dạng HEX
x_hex = dec2hex(mod(x_int, 2^B), 4);  % Chuyển số bù 2 sang hex 16-bit

% Xuất file HEX
fid = fopen('sine_wave_10b.hex', 'w');    % Mở file để ghi
for i = 1:length(x_hex)
    fprintf(fid, '%s\n', x_hex(i, :)); % Ghi từng dòng một giá trị HEX 16-bit
end
fclose(fid);  

disp('File HEX đã được tạo thành công!');
