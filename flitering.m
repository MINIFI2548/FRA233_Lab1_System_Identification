y = data{1}.Values.Data;

fs = 1000; % ความถี่ในการสุ่มตัวอย่าง (Sampling Frequency) ของคุณ
lpFilt = designfilt('lowpassiir', 'PassbandFrequency', 1, ...
                    'StopbandFrequency', 20, 'SampleRate', fs);
y_clean = filtfilt(lpFilt, y);
y_clean2 = filter(lpFilt, y);

t = (0:length(y)-1)/fs;
plot(t, y, 'Color', [0.7 0.7 0.7], 'DisplayName', 'Original');
hold on;
plot(t, y_clean, 'LineWidth', 1.5, 'DisplayName', 'Filtered');
hold on;
plot(t, y_clean2, 'LineWidth', 1.5, 'DisplayName', 'Filtered - 2');
legend;