torque = data{2}.Values.Data; 
omega = data{1}.Values.Data; 

fs = 1000; % ความถี่ในการสุ่มตัวอย่าง (Sampling Frequency) ของคุณ
lpFilt = designfilt('lowpassiir', 'PassbandFrequency', 1, ...
                    'StopbandFrequency', 125, 'SampleRate', fs);
omega_clean = filtfilt(lpFilt, omega);
torque_clean = filtfilt(lpFilt, torque);

% plot(omega_clean, torque_clean)
% hold on
plot(omega_clean, torque)