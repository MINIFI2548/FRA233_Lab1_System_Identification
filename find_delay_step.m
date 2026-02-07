usePrefix = true; % true = ใช้ Prefix, false = ใช้รายชื่อใน targetFiles
prefix = 'Raw_Test_'; 
folderName = 'Raw Signal'; % ระบุชื่อโฟลเดอร์
targetFiles = {"step 1.mat"};

% ตรวจสอบการเลือกไฟล์
if usePrefix
    % filesInfo = dir([prefix, '*.mat']);
    filesInfo = dir(fullfile(folderName, [prefix, '*.mat']));
    fileList = {filesInfo.name};
else
    fileList = targetFiles;
end
numFiles = length(fileList);

total_time_diff = 0;

for i = 1:numFiles
    filename = fileList{i};
    fullPath = fullfile(folderName, filename);

    % โหลดไฟล์ข้อมูล
    dataset = load(fullPath);% หรือชื่อตัวแปรที่ปรากฏใน Workspace
    dataset = dataset.data;
    
    % ดึงข้อมูลสัญญาณ
    input_data = dataset.get('input signal').Values;
    motor_data = dataset.get('Motor Angular Velocity').Values;
    
    % 1. หาเวลาที่ input_signal เริ่มเปลี่ยนแปลง
    % สมมติว่าหาจุดที่ค่าต่างจากค่าเริ่มต้น (ค่าแรก)
    input_values = input_data.Data;
    input_time = input_data.Time;
    idx_input = find(input_values ~= input_values(1), 1);
    t_input_change = input_time(idx_input);
    
    % 2. หาเวลาที่ Motor Angular Velocity เริ่มเปลี่ยนจาก 0
    motor_values = motor_data.Data;
    motor_time = motor_data.Time;
    % ใช้ threshold เล็กน้อยเพื่อป้องกัน Noise (เช่น 1e-4)
    idx_motor = find(abs(motor_values) > 1e-4, 1);
    t_motor_change = motor_time(idx_motor);
    
    % 3. คำนวณความต่างของเวลา
    time_diff = t_motor_change - t_input_change;
    total_time_diff = total_time_diff + time_diff;
    % แสดงผลลัพธ์
    fprintf(filename);
    fprintf('\n');
    fprintf('Input Signal เริ่มเปลี่ยนที่เวลา: %.5f s\n', t_input_change);
    fprintf('Motor Velocity เริ่มเปลี่ยนที่เวลา: %.5f s\n', t_motor_change);
    fprintf('ความต่างของเวลา (Delay): %.5f s\n', time_diff);
end 
fprintf('ความต่างของเวลาเฉลี่ย (Delay): %.5f s\n', total_time_diff/length(filesInfo));