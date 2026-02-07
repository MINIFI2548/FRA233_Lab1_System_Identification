input_folder = 'Raw Signal';      % เปลี่ยนชื่อโฟลเดอร์ต้นทางที่นี่
target_folder = 'Shifted_Results'; % ชื่อโฟลเดอร์สำหรับบันทึกผลลัพธ์
usePrefix = true;                 % true = ใช้ Prefix, false = ใช้รายชื่อใน targetFiles
prefix = 'chirp '; 
targetFiles = {'sine 1.mat'};      % รายชื่อไฟล์ในโฟลเดอร์ (ไม่ต้องใส่ path)

% สร้างโฟลเดอร์ปลายทางหากยังไม่มีอยู่
if ~exist(target_folder, 'dir')
    mkdir(target_folder);
end

% ตรวจสอบการเลือกไฟล์จากโฟลเดอร์ที่กำหนด
if usePrefix
    filesInfo = dir(fullfile(input_folder, [prefix, '*.mat']));
    fileList = {filesInfo.name};
else
    fileList = targetFiles;
end

numFiles = length(fileList);

fprintf('\n--- ผลการวิเคราะห์ ');

for i = 1:numFiles
    filename = fileList{i};
    fullInputPath = fullfile(input_folder, filename); % สร้าง path เต็มเพื่อเรียกไฟล์
    
    % 2. โหลดไฟล์ข้อมูล
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

    motor_ts = ds.get('Motor Angular Velocity');
    if isa(motor_ts, 'Simulink.SimulationData.Signal')
        motor_ts = motor_ts.Values;
    end 
    
    input_ts = ds.get('input signal');
    if isa(input_ts, 'Simulink.SimulationData.Signal')
        input_ts = input_ts.Values;
    end 
    
    t = input_ts.Time;
    t_in = input_ts.Time;
    v_in = input_ts.Data;
    v_m = motor_ts.Data;
    t_m = motor_ts.Time;
    % ปรับสเกลให้เป็น 0-1 เพื่อเทียบรูปทรงคลื่นได้ชัดๆ
    v_in_norm = (v_in - min(v_in)) / (max(v_in) - min(v_in));
    v_m_norm = (v_m - min(v_m)) / (max(v_m) - min(v_m));

    % คำนวณความหน่วง (Delay Analysis) ---
    % หาค่า Phase Shift โดยใช้ Cross-correlation
    [corr, lags] = xcorr(v_m, v_in);
    [~, I] = max(corr);
    t_delay = lags(I) * mean(diff(t)); % แปลงจาก Lag เป็นวินาที
    
    % คำนวณเฟส (สำหรับ 1Hz: 1 รอบ = 1 วินาที = 360 องศา)
    freq = 1; % 1 Hz ตามชื่อไฟล์
    phase_shift = t_delay * 360 * freq;

    fprintf(filename);
    fprintf('\n');
    fprintf('เวลาที่หน่วง (Time Delay): %.6f วินาที\n', abs(t_delay));
    fprintf('ความต่างเฟส (Phase Shift): %.2f องศา\n', abs(phase_shift));
    if abs(phase_shift) > 5
        fprintf('สถานะ: พบความหน่วงอย่างชัดเจน (กราฟ X-Y จะเป็นวงรี)\n');
    else
        fprintf('สถานะ: ระบบตอบสนองได้เร็วมาก (กราฟ X-Y เกือบเป็นเส้นตรง)\n');
    end
    % ==========================================
    % ทำการเลื่อนแกนเวลา
    % ==========================================
    t_m_shifted = t_m - t_delay;
    
    % 2. ตัด 1 วินาทีสุดท้ายของกราฟออก
    original_end_time = t_in(end);
    new_end_time = original_end_time - 2.0; % ลบออก 2 วินาที
    
    % กรองช่วงเวลาใหม่
    clip_idx = t_in <= new_end_time;
    t_final = t_in(clip_idx);
    v_in_final = v_in(clip_idx);
    v_m_final = interp1(t_m_shifted, v_m, t_final, 'linear', 0); % จัดการส่วน 0 [cite: 40, 51]
    
    % 2. สร้างโครงสร้างข้อมูลให้เหมือนไฟล์ต้นฉบับ
    % สร้าง Timeseries ใหม่ [cite: 38, 72]
    ts_input_new = timeseries(v_in_final, t_final);
    ts_input_new.Name = 'input signal';
    
    ts_motor_new = timeseries(v_m_final, t_final);
    ts_motor_new.Name = 'Motor Angular Velocity';
    
    % สร้าง Dataset ใหม่และเพิ่มข้อมูลเข้าไป (ลักษณะเดียวกับ Simulink Dataset) 
    data = Simulink.SimulationData.Dataset; 
    data = data.addElement(ts_input_new, 'input signal');
    data = data.addElement(ts_motor_new, 'Motor Angular Velocity');
    
    % 5. บันทึกไฟล์ลง Folder
    output_name = fullfile(target_folder, ['Aligned_', filename]);
    save(output_name, 'data');

    % 6. พล็อตกราฟตรวจสอบ
    figure('Name', 'Manual Shift & Trim Result');
    subplot(2,1,1);
    plot(t_in, v_in, 'b', t_m, v_m, 'r');
    title('Original Signal (เทียบกับเวลาเดิม)');
    xlabel('Time (s)'); grid on;
    legend('Input', 'Motor');
    
    subplot(2,1,2);
    plot(t_final, v_in_final, 'b', t_final, v_m_final, 'm', 'LineWidth', 1);
    title(['Shifted (', num2str(t_delay), 's) and Trimmed (Last 1s removed)']);
    xlabel('Time (s)'); xlim([0 new_end_time]); grid on;
    legend('Input (Trimmed)', 'Motor (Shifted & Trimmed)');
    
    fprintf('เสร็จสิ้น:\n');
    fprintf('- เลื่อนสัญญาณ Motor ไป %.4f วินาที\n', t_delay);
    fprintf('- ตัดท้ายออก 1 วินาที (จบที่เวลา %.2f s)\n', new_end_time);
    fprintf('- บันทึกไฟล์ที่: %s\n', output_name);
end 