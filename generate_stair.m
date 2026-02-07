%% 1. กำหนดค่าเริ่มต้น
fs = 1/0.0005;      % Sampling Frequency (2000 Hz)
amp_max = 12;       
on_time = 2;        
off_time = 2;       
loop_gap_time = 4;  % เว้นระหว่างลูก (Loop) 4 วินาที
num_loops = 5;      

%% 2. สร้างสัญญาณ Stair Step 1 รอบ (1-12V)
one_stair_cycle = []; 
for v = 1:amp_max
    t_on = 0:1/fs:(on_time - 1/fs);
    on_part = ones(size(t_on)) * v;
    
    t_off = 0:1/fs:(off_time - 1/fs);
    off_part = zeros(size(t_off));
    
    one_stair_cycle = [one_stair_cycle, on_part, off_part];
end

%% 3. สร้างช่วงเว้นวรรคระหว่าง Loop (Gap)
t_gap = 0:1/fs:(loop_gap_time - 1/fs);
gap_part = zeros(size(t_gap));

%% 4. ประกอบร่าง 5 รอบ พร้อมเว้นวรรค 4 วิระหว่างรอบ
full_signal_data = [gap_part];
for i = 1:num_loops
    full_signal_data = [full_signal_data, one_stair_cycle];
    
    % ถ้าไม่ใช่รอบสุดท้าย ให้ใส่ช่วงเว้นวรรค (Gap) ต่อท้าย
    if i < num_loops
        full_signal_data = [full_signal_data, gap_part];
    end
end

%% 5. สร้างแกนเวลาและแปลงเป็น Timeseries
t_total = (0:length(full_signal_data)-1) / fs;
ref_input_signal = timeseries(full_signal_data', t_total');
ref_input_signal.Name = 'Staircase_with_Gap';

%% 6. แสดงผลกราฟ
figure('Color', 'w');
plot(ref_input_signal, 'LineWidth', 1.2, 'Color', [0.1 0.6 0.2]);
grid on;
title('Staircase 1-12V: 5 Loops with 4s Gap between each loop');
xlabel('Time (seconds)');
ylabel('Amplitude (V)');