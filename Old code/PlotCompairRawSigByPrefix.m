% 1. กำหนดคำขึ้นต้นที่ต้องการค้นหา
prefix = 'RAMP ';

% 2. ใช้ฟังก์ชัน dir ร่วมกับ * (Wildcard) เพื่อดึงข้อมูลไฟล์
% '*' หมายถึง "อะไรก็ได้ต่อจากนี้"
filePattern = [prefix, '*']; 
files = dir(filePattern);
files = files(~[files.isdir]);

% ดึงเฉพาะชื่อไฟล์ออกมาเก็บไว้ใน Cell Array (ลิสต์)
fileList = {files.name}';

% แสดงผลลัพธ์
% disp('รายชื่อไฟล์ที่ค้นพบ:')
% disp(fileList)

loadData = struct('name', {}, 'data', {});

for i = 1:length(files)
    filename = fileList{i};
    loadData(i).name = filename;
    
    % ตรวจสอบนามสกุลไฟล์เพื่อเลือกวิธีโหลดที่เหมาะสม
    [~, ~, ext] = fileparts(filename);
   try
        if strcmpi(ext, '.mat')
            % สำหรับไฟล์ .mat
            content = load(filename);
            loadData(i).data = content.data; 
        elseif strcmpi(ext, '.csv') || strcmpi(ext, '.txt')
            % สำหรับไฟล์ตัวเลข/ข้อความ
            loadData(i).data = readmatrix(filename); 
        else
            % ไฟล์ประเภทอื่นๆ
            loadData(i).data = 'Unsupported format';
        end
    catch ME
        fprintf('ไม่สามารถโหลดไฟล์ %s ได้: %s\n', filename, ME.message);
        loadData(i).data = [];
    end
end

disp('โหลดข้อมูลเสร็จสิ้น!')

figure;
hold on;
grid on;
labels = {};

for i = 1:length(files)
    filename = files(i).name;
    
    % 2. โหลดไฟล์ (ไฟล์ 7.3 จะถูกโหลดเป็น struct)
    content = load(filename);
    
    % ตรวจสอบว่ามีตัวแปรชื่อ 'data' หรือไม่ (ตามโครงสร้างไฟล์ที่ส่งมา)
    if isfield(content, 'data')
        ds = content.data; % นี่คือ Simulink.SimulationData.Dataset
        
        % 3. ดึงสัญญาณตัวแรกออกมา (Signal 1)
        % ปกติ Dataset จะเก็บ Signal ไว้ภายใน
        sig = ds.get(1); 
        
        % ดึง Time และ Data (จาก timeseries object)
        time = sig.Values.Time;
        val  = sig.Values.Data;
        
        % 4. พล็อตกราฟ (Data เทียบกับ Time)
        plot(time, val, 'LineWidth', 1.5);
        
        % 5. จัดการ Label (ตัด Prefix และ นามสกุลออก)
        [~, nameOnly, ~] = fileparts(filename);
        cleanLabel = strrep(nameOnly, prefix, ''); % ตัดส่วนที่เป็น prefix ออก
        labels{end+1} = cleanLabel;
        
    else
        fprintf('ไม่พบตัวแปร "data" ในไฟล์ %s\n', filename);
    end
end

% 6. ตกแต่งกราฟ
if ~isempty(labels)
    legend(labels, 'Interpreter', 'none', 'Location', 'best');
end
title(['Signal Comparison (Prefix: ', prefix, ')']);
xlabel('Time (s)');
ylabel('Value / Index');
hold off;