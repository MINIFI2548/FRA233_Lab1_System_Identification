fs = 1/0.0005; 
f = 1;     
amp = 12;  

% 1. ปิดก่อน 2 วิแรก (ใหม่ตามโจทย์)
t_init_off = 0:1/fs:(2 - 1/fs);
init_off = zeros(size(t_init_off));

% 2. สัญญาณ STEP
step_duration = 2; 
step_height = 12;  
t_step = 0:1/fs:(step_duration - 1/fs);
step_sig = ones(size(t_step)) * step_height;

% 3. ปิดคั่นก่อน Sine 2 วิ
t_off_gap = 0:1/fs:(4 - 1/fs);
off_gap = zeros(size(t_off_gap));

% 4. Sine Wave 20 ลูก (20 วินาที)
t_on20 = 0:1/fs:(20 - 1/fs);
on20 = amp * sin(2*pi*f*t_on20); 

% 5. ปิดท้าย (3 วิ + 4 วิ = 7 วินาที)
t_off_end = 0:1/fs:(7 - 1/fs);
off_end = zeros(size(t_off_end));

% --- รวมสัญญาณทั้งหมด ---
% ลำดับ: [ปิด 2วิ] -> [Step] -> [ปิด 2วิ] -> [Sine 20ลูก] -> [ปิดท้าย]
combined_data = [init_off, step_sig, off_gap, on20, off_end];

% สร้างแกนเวลาและ Timeseries
t_total = (0:length(combined_data)-1) / fs;
ts = timeseries(combined_data', t_total');
ts.Name = 'Full Sequence Signal';

ref_input_signal = ts;

% --- Plot ---
figure;
plot(ts, 'LineWidth', 1.5, 'Color', [0.8500 0.3250 0.0980]);
grid on;
title('Signal: Initial Off -> Step -> Off -> 20 Sine Waves -> Final Off');
xlabel('Time (seconds)');
ylabel('Amplitude');
ylim([-15 15]);