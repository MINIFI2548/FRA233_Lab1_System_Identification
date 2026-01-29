% ดึงข้อมูลจาก timeseries
d_raw = data.Data;
d = d_raw;

Fs = 1000;
T = 1/Fs;
L = length(d);
t = (0:L-1)*T;

Y = fft(d_raw);