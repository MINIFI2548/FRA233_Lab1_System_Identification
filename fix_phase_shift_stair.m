% --- MATLAB Script: Per-Step Alignment (Shift each step individually) ---
input_folder = 'Raw Signal';      % เปลี่ยนชื่อโฟลเดอร์ต้นทางที่นี่
target_folder = 'Test Signal'; % ชื่อโฟลเดอร์สำหรับบันทึกผลลัพธ์
usePrefix = false;                 % true = ใช้ Prefix, false = ใช้รายชื่อใน targetFiles
prefix = 'stair '; 
targetFiles = {'Raw_Test_Stair.mat'};      % รายชื่อไฟล์ในโฟลเดอร์ (ไม่ต้องใส่ path)

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
    
    % เข้าถึง Dataset
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
    
    input_ts = ds.get('input signal').Values;
    motor_ts = ds.get('Motor Angular Velocity').Values;
    
    t_in = input_ts.Time;
    v_in = squeeze(input_ts.Data);
    t_m = motor_ts.Time;
    v_m = squeeze(motor_ts.Data); % ใช้ squeeze เพื่อความชัวร์เรื่องมิติข้อมูล
    
    % 1. หาตำแหน่งขอบขาขึ้นของ Input ทั้งหมด
    rising_edges = find(diff(v_in) > 0) + 1;
    % เพิ่มจุดสุดท้ายของสัญญาณเข้าไปเพื่อกำหนดขอบเขตลูกสุดท้าย
    segment_limits = [rising_edges; length(t_in)];
    
    % เตรียมตัวแปรสำหรับเก็บผลลัพธ์ที่ Aligned แล้ว
    v_m_aligned = zeros(size(v_in));
    threshold = 0.01; % ปรับตาม Noise
    
    fprintf('--- กำลังวิเคราะห์และ Shift แยกรายลูก: %s ---\n', filename);
    
    % 2. วนลูปเพื่อจัดการแต่ละ Step (Local Alignment)
    for j = 1:length(segment_limits)-1
        start_idx = segment_limits(j);
        end_idx = segment_limits(j+1)-1;
        
        t_target_seg = t_in(start_idx:end_idx); % เวลาเป้าหมาย
        t_start_input = t_in(start_idx);        % เวลาที่ Input เริ่มขยับ
        
        % หาจุดตอบสนองของ Motor ในช่วงนี้
        idx_resp = find(t_m >= t_start_input & v_m > threshold, 1);
        
        if ~isempty(idx_resp)
            local_delay = t_m(idx_resp) - t_start_input;
            t_m_shifted_local = t_m - local_delay;
            
            % Interpolation และจัดการส่วนที่ขาดหายด้วย 0
            v_m_aligned(start_idx:end_idx) = interp1(t_m_shifted_local, v_m, t_target_seg, 'linear', 0);
            fprintf('  ลูกที่ %d: Delay = %.6f s\n', j, local_delay);
        else
            v_m_aligned(start_idx:end_idx) = v_m(start_idx:end_idx);
        end
    end
    
    % --- เพิ่มเติม: การตัด 1 วินาทีสุดท้ายออก ---
    new_end_time = t_in(end) - 1.0;
    clip_idx = t_in <= new_end_time;
    
    t_final = t_in(clip_idx);
    v_in_final = v_in(clip_idx);
    v_m_final = v_m_aligned(clip_idx);
    
    % 3. สร้าง Timeseries และ Dataset ใหม่ให้เหมือนโครงสร้างเดิม
    ts_input_new = timeseries(v_in_final, t_final);
    ts_input_new.Name = 'input signal';
    
    ts_motor_new = timeseries(v_m_final, t_final);
    ts_motor_new.Name = 'Motor Angular Velocity';
    
    % สร้างตัวแปร 'data' เป็น Dataset ตามแบบไฟล์ตัวอย่าง 
    data = Simulink.SimulationData.Dataset; 
    data = data.addElement(ts_input_new, 'input signal');
    data = data.addElement(ts_motor_new, 'Motor Angular Velocity');
    
    % 4. บันทึกไฟล์ลง Folder โดยใช้ชื่อตัวแปรว่า 'data'
    output_name = fullfile(target_folder, ['Aligned_', filename]);
    save(output_name, 'data');
    
    % 5. พล็อตกราฟเปรียบเทียบ
    figure('Name', ['Alignment: ', filename]);
    subplot(2,1,1);
    plot(t_in, v_in, 'b', t_m, v_m, 'r');
    title(['ต้นฉบับ: ', filename]);
    grid on; legend('Input', 'Motor');
    
    subplot(2,1,2);
    plot(t_final, v_in_final, 'b', t_final, v_m_final, 'm', 'LineWidth', 1);
    title('หลัง Shift แยกรายลูก และตัดท้าย 1 วินาที');
    grid on; legend('Input', 'Motor (Aligned & Trimmed)');
    
    fprintf('เสร็จสิ้น: บันทึกไฟล์ในชื่อตัวแปร "data" ที่ %s\n\n', output_name);
end