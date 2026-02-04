% ดึงข้อมูลจาก timeseries
d_raw = data{1}.Values.Data;
d = d_raw;

Fs = 1000;
T = 1/Fs;
L = length(d);
t = (0:L-1)*T;

Y = fft(d);

plot(Fs/L*(-L/2:L/2-1),abs(fftshift(Y)),"LineWidth",3)
title("fft Spectrum in the Positive and Negative Frequencies")
xlabel("f (Hz)")
ylabel("|fft(X)|")
grid on