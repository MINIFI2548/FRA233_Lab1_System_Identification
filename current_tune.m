Nagative_data = load("current_tune_-4.6A.mat");
%  ค่าเฉลี่ย 10 วิสุดท้าย
Nagative_mean = double(mean(Nagative_data.data{1}.Values.data(end-9999:end)));

Positive_data = load("current_tune_4A.mat");
%  ค่าเฉลี่ย 10 วิสุดท้าย
Positive_mean = double(mean(Positive_data.data{1}.Values.data(end-9999:end)));

zero_data = load("current_tune_A.mat");
%  ค่าเฉลี่ย 10 วิสุดท้าย
zero_mean = double(mean(zero_data.data{1}.Values.data(end-9999:end)));

y = [-4.6 0 4];
x = [Nagative_mean, zero_mean, Positive_mean];

p = polyfit(x, y, 1);   % ดีกรี 1 = เส้นตรง
m = p(1)
b = p(2)