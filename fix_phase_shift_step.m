input_folder = 'Raw Signal';      % เปลี่ยนชื่อโฟลเดอร์ต้นทางที่นี่
target_folder = 'Shifted_Results'; % ชื่อโฟลเดอร์สำหรับบันทึกผลลัพธ์
usePrefix = true;                 % true = ใช้ Prefix, false = ใช้รายชื่อใน targetFiles
prefix = 'step '; 
targetFiles = {'step 1.mat'};      % รายชื่อไฟล์ในโฟลเดอร์ (ไม่ต้องใส่ path)

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

for i = 1:numFiles
    filename = fileList{i};
    fullInputPath = fullfile(input_folder, filename); % สร้าง path เต็มเพื่อเรียกไฟล์
    
    % 2. โหลดไฟล์ข้อมูล
    if exist(fullInputPath, 'file')
        dataset_struct = load(fullInputPath);
        if isfield(dataset_struct, 'data')
            dataset = dataset_struct.data;
        else
            dataset = dataset_struct; 
        end
    else
        warning('ไม่พบไฟล์ %s ในโฟลเดอร์ %s', filename, input_folder);
        continue;
    end
    
    % 3. ดึงข้อมูลสัญญาณ
    input_ts = dataset.get('input signal').Values;
    motor_ts = dataset.get('Motor Angular Velocity').Values;
    
    input_values = input_ts.Data;
    input_time = input_ts.Time;
    motor_values = motor_ts.Data;
    motor_time = motor_ts.Time;
    
    % 4. คำนวณการเลื่อน (ตาม Logic ขอบขาขึ้นในโค้ดของคุณ)
    idx_input = find(input_values ~= input_values(1), 1);
    t_input_change = input_time(idx_input);
    
    threshold = 1e-4;
    idx_motor = find(abs(motor_values) > threshold, 1);
    t_motor_change = motor_time(idx_motor);
    
    time_diff = t_motor_change - t_input_change;
    
    % 5. ทำการเลื่อน (Shift) และตัด 1 วินาทีสุดท้าย
    shifted_time = motor_time - time_diff;
    
    % กำหนดเวลาสิ้นสุดใหม่ (ตัดท้ายออก 1 วินาที)
    new_end_time = input_time(end) - 1.0;
    
    % กรองข้อมูลในช่วงเวลาที่ต้องการ
    keep_idx = input_time <= new_end_time;
    t_final = input_time(keep_idx);
    v_in_final = input_values(keep_idx);
    
    % Interpolate ให้ Motor ลงแกนเวลาเดียวกับ Input และเติม 0 ในส่วนที่ขาด
    v_m_final = interp1(shifted_time, motor_values, t_final, 'linear', 0);
    
    % 6. สร้างโครงสร้างข้อมูลให้เหมือนไฟล์ต้นฉบับ (Dataset)
    input_ts_new = timeseries(v_in_final, t_final);
    input_ts_new.Name = 'input signal';
    
    motor_ts_new = timeseries(v_m_final, t_final);
    motor_ts_new.Name = 'Motor Angular Velocity';
    
    % เก็บลงใน Simulink Dataset เพื่อให้เหมือนไฟล์ตัวอย่าง
    data = Simulink.SimulationData.Dataset; 
    data = data.addElement(input_ts_new, 'input signal');
    data = data.addElement(motor_ts_new, 'Motor Angular Velocity');
    
    % 7. บันทึกไฟล์
    output_filename = fullfile(target_folder, ['Aligned_', filename]);
    save(output_filename, 'data');
    
    % 8. แสดงผลลัพธ์
    fprintf('ประมวลผลไฟล์: %s (Delay: %.5f s)\n', filename, time_diff);
    
    % พล็อตกราฟตรวจสอบ
    figure('Name', filename);
    plot(t_final, v_in_final, 'b', 'DisplayName', 'Input (Trimmed)'); hold on;
    plot(t_final, v_m_final, 'r', 'DisplayName', 'Motor (Shifted & Trimmed)');
    grid on; legend; title(['Alignment Result: ', filename]);
end