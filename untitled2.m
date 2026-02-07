% --- MATLAB Script: Custom Trim & Manual Shift for Motor Velocity ---

% ==========================================
% 1. ตั้งค่าพารามิเตอร์ (ปรับเปลี่ยนได้ที่นี่)
% ==========================================
trim_head_sec = 6;   % ต้องการตัดหัวออกกี่วินาที
trim_tail_sec = 2;   % ต้องการตัดท้ายออกกี่วินาที
manual_shift_sec = 0.0035; % ต้องการเลื่อน Motor ไปทางซ้ายกี่วินาที (ถ้าเลื่อนขวาให้ใส่ค่าติดลบ)

input_folder = 'Raw Signal';      % โฟลเดอร์ต้นทาง
target_folder = 'Test Signal'; % โฟลเดอร์ปลายทาง
usePrefix = false;                 
prefix = 'stair '; 
targetFiles = {'Raw_Test_Chirp.mat'};      

% ==========================================
% 2. จัดการไฟล์และโฟลเดอร์
% ==========================================
if ~exist(target_folder, 'dir'), mkdir(target_folder); end

if usePrefix
    filesInfo = dir(fullfile(input_folder, [prefix, '*.mat']));
    fileList = {filesInfo.name};
else
    fileList = targetFiles;
end

numFiles = length(fileList);

for i = 1:numFiles
    filename = fileList{i};
    fullInputPath = fullfile(input_folder, filename);
    
    if exist(fullInputPath, 'file')
        dataset_struct = load(fullInputPath);
        if isfield(dataset_struct, 'data')
            ds = dataset_struct.data;
        else
            ds = dataset_struct; 
        end
    else
        warning('ไม่พบไฟล์ %s ในโฟลเดอร์ %s', filename, input_folder);
        continue;
    end
    
    % ดึงข้อมูลเดิม
    input_ts = ds.get('input signal').Values;
    motor_ts = ds.get('Motor Angular Velocity').Values;
    
    t_in = input_ts.Time;
    v_in = squeeze(input_ts.Data);
    t_m = motor_ts.Time;
    v_m = squeeze(motor_ts.Data);
    
    % ==========================================
    % 3. การประมวลผล (Shift & Trim)
    % ==========================================
    
    % เลื่อนแกนเวลาของมอเตอร์
    t_m_shifted = t_m - manual_shift_sec;
    
    % คำนวณขอบเขตเวลาใหม่หลังการตัดหัวและท้าย
    new_start_time = t_in(1) + trim_head_sec;
    new_end_time = t_in(end) - trim_tail_sec;
    
    % ตรวจสอบความถูกต้องของเวลา
    if new_start_time >= new_end_time
        warning('ค่าการตัดหัวและท้ายมากเกินไปสำหรับไฟล์ %s', filename);
        continue;
    end
    
    % สร้าง Index สำหรับช่วงเวลาใหม่
    clip_idx = (t_in >= new_start_time) & (t_in <= new_end_time);
    t_final = t_in(clip_idx);
    v_in_final = v_in(clip_idx);
    
    % ปรับจูนแกนเวลาให้กลับมาเริ่มที่ 0 (ถ้าต้องการ) 
    % t_final = t_final - t_final(1); 
    
    % Resample ข้อมูลทั้งคู่ลงบนแกนเวลาใหม่
    v_m_final = interp1(t_m_shifted, v_m, t_final, 'linear', 0);
    
    % ==========================================
    % 4. บันทึกในโครงสร้างเดิม (Dataset)
    % ==========================================
    
    % สร้าง Timeseries
    ts_in = timeseries(v_in_final, t_final);
    ts_in.Name = 'input signal';
    
    ts_motor = timeseries(v_m_final, t_final);
    ts_motor.Name = 'Motor Angular Velocity';
    
    % บรรจุลงใน Dataset ชื่อ 'data'
    data = Simulink.SimulationData.Dataset; 
    data = data.addElement(ts_in, 'input signal');
    data = data.addElement(ts_motor, 'Motor Angular Velocity');
    
    % บันทึกไฟล์
    output_name = fullfile(target_folder, ['Processed_', filename]);
    save(output_name, 'data');
    
    % ==========================================
    % 5. แสดงผลและพล็อตกราฟ
    % ==========================================
    fprintf('ไฟล์: %s -> ตัดหัว: %.2fs, ตัดท้าย: %.2fs, Shift: %.4fs\n', ...
            filename, trim_head_sec, trim_tail_sec, manual_shift_sec);
        
    figure('Name', ['Processed: ', filename]);
    plot(t_final, v_in_final, 'b', 'LineWidth', 1); hold on;
    plot(t_final, v_m_final, 'r--', 'LineWidth', 1);
    grid on; legend('Input Signal', 'Motor Velocity');
    % title(['Shifted: ', num2str(manual_shift_time), 's | Trimmed Head/Tail']);
end