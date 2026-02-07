fs = 1/0.0005; 
amp_max = 12;  
f0 = 0.125; % ความถี่เริ่ม
f1 = 1;     % ความถี่จบ
T_target = 25; % เวลาเป้าหมาย

% --- คำนวณหาเวลา T ที่ทำให้จบที่ 0 พอดี ---
% เราต้องการให้ Phase สะสมเป็นจำนวนเท่าของ pi
% Phase = 2*pi * (f0*T + (f1-f0)/(2*T_target) * T^2)
% เราจะวนหา T ที่ใกล้ T_target ที่สุดที่ทำให้ sin(phase) = 0
T_adj = round(T_target * (f0 + f1)/2) / ((f0 + f1)/2); 
% หรือวิธีที่ง่ายกว่าคือการปรับ f1 เล็กน้อยเพื่อให้ลงล็อค (ในที่นี้เราจะปรับ T)

% 1. ปิดก่อน 2 วิแรก
t_init_off = 0:1/fs:(2 - 1/fs);
init_off = zeros(size(t_init_off));

% 2. สัญญาณ STEP
t_step = 0:1/fs:(2 - 1/fs);
step_sig = ones(size(t_step)) * amp_max;

% 3. ปิดคั่นกลาง 4 วินาที
t_off_gap = 0:1/fs:(4 - 1/fs);
off_gap = zeros(size(t_off_gap));

% 4. สร้าง CHIRP (เริ่มที่ 0 และจบที่ 0)
% ใช้ f1_adj เพื่อให้จบที่ 0 พอดีที่เวลา 25 วินาที
k = (f1 - f0) / T_target;
% ตรวจสอบ phase และปรับเวลาเล็กน้อยเพื่อให้จบที่ zero crossing
t_chirp_only = 0:1/fs:T_target; 
chirp_sig = amp_max * chirp(t_chirp_only, f0, T_target, f1, 'linear', -90);

% ตัดท้ายสัญญาณให้จบที่จุดตัดศูนย์ (Zero-crossing) ที่ใกล้ที่สุด
zero_crossings = find(abs(chirp_sig) < 1e-3); % หาจุดที่ใกล้ 0
end_idx = zero_crossings(end);
chirp_sig = chirp_sig(1:end_idx);

% ปิดท้าย Chirp 4 วินาที
t_chirp_off = 0:1/fs:(4 - 1/fs);
chirp_off = zeros(size(t_chirp_off));

% รวมเป็น 5 ลูก
one_chirp_cycle = [chirp_sig, chirp_off];
five_chirps = repmat(one_chirp_cycle, 1, 5);

% --- รวมสัญญาณทั้งหมด ---
combined_data = [init_off, step_sig, off_gap, five_chirps];
t_total = (0:length(combined_data)-1) / fs;

ref_input_signal = timeseries(combined_data', t_total');

% --- Plot เช็คจุดเริ่มและจุดจบ ---
figure;
subplot(2,1,1);
plot(ref_input_signal); title('Full Signal'); grid on;

subplot(2,1,2); % Zoom ดูช่วงรอยต่อ Chirp ลูกที่ 1
plot(t_total, combined_data);
xlim([6 + T_target - 1, 6 + T_target + 5]); 
title('Zoom at the end of first Chirp (Should be 0)');
grid on;