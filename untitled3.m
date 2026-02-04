fs = 1000;              % Sampling frequency
t = 0:1/fs:1-1/fs;      % Time vector
f = 5;                  % Frequency 5 Hz

% สร้างสัญญาณ 2 ตัวที่มี Phase shift ต่างกัน
x = sin(2*pi*f*t);
y = sin(2*pi*f*t + pi/4); % เลื่อนไป pi/4 (45 องศา)

% หา Cross-correlation
[cor, lags] = xcorr(x, y);
[~, idx] = max(cor);
delay = lags(idx);

% คำนวณเฟสที่ต่างกัน (หน่วยเป็นองศา)
phase_diff = (delay/fs) * f * 360;
fprintf('Phase Shift: %.2f degrees\n', phase_diff);

plot(x)
hold on 
plot(y)
hold off
grid on