titleName = 'Fliterd Signal Comparison';
% --- 1. ตั้งค่าการเลือกไฟล์และฟิลเตอร์ ---
usePrefix = false; % true = ใช้ Prefix, false = ใช้รายชื่อใน targetFiles
prefix = 'Ramp '; 
targetFiles = {'Ramp 30Hz-1.mat', 'Ramp 152Hz-1.mat', 'Ramp 7676Hz-1.mat'}; 

fs = 1000; % Sampling Frequency
lpFilt = designfilt('lowpassiir', 'PassbandFrequency', 1, ...
                    'StopbandFrequency', 25, 'SampleRate', fs);

% ตรวจสอบการเลือกไฟล์
if usePrefix
    filesInfo = dir([prefix, '*.mat']);
    fileList = {filesInfo.name};
else
    fileList = targetFiles;
end

numFiles = length(fileList);
labels = {}; % ลิสต์สำหรับเก็บชื่อที่จะแสดงใน Legend

% 2. เตรียมโครงสร้างเก็บข้อมูล
loadData = struct('name', {}, 'data', {});
for i = 1:length(fileList)
    filename = fileList{i};
    if exist(filename, 'file') ~= 2
        fprintf('ไม่พบไฟล์: %s (ข้ามไป...)\n', filename);
        continue;
    end
    
    loadData(i).name = filename;
    [~, ~, ext] = fileparts(filename);
    
    try
        if strcmpi(ext, '.mat')
            content = load(filename);
            if isfield(content, 'data')
                loadData(i).data = content.data;
            else
                loadData(i).data = content;
            end
        elseif strcmpi(ext, '.csv') || strcmpi(ext, '.txt')
            loadData(i).data = readmatrix(filename); 
        end
    catch ME
        fprintf('โหลดไฟล์ %s ไม่สำเร็จ: %s\n', filename, ME.message);
    end
end

% 3. การพล็อตกราฟ
figure;
labels = {};

% --- Subplot 1: สัญญาณที่ 1 ---
subplot(2, 1, 1);
hold on; grid on;
for i = 1:length(loadData)
    if isempty(loadData(i).data), continue; end
    
    if isa(loadData(i).data, 'Simulink.SimulationData.Dataset')
        sig = loadData(i).data.get(1); % ดึงตัวแปรที่ 1
        time = sig.Values.Time;
        val  = sig.Values.Data;
    else
        data = loadData(i).data;
        if size(data, 2) >= 2
            time = data(:, 1);
            val  = data(:, 2); % คอลัมน์ที่ 2 (สัญญาณที่ 1)
        else
            time = 1:length(data);
            val  = data;
        end
    end
    % ประมวลผล Filter
    val_filtfilt = filtfilt(lpFilt, val);
    plot(time, val_filtfilt, 'LineWidth', 1.5);
    % เก็บชื่อ Label (ทำเฉพาะใน loop แรก)
    [~, nameOnly, ~] = fileparts(loadData(i).name);

    cleanName = strrep(nameOnly, prefix, '');
    dashIdx = strfind(cleanName, '-');
    if ~isempty(dashIdx)
        cleanName = cleanName(1:dashIdx(end)-1);
    end
    
    labels{end+1} = cleanName;
end
title([titleName]);
legend(labels, 'Interpreter', 'none', 'Location', 'best');
xlabel('Time (s)');
ylabel('Omega(Rad/s)');

% --- Subplot 1: สัญญาณที่ 2 Input signal ---
subplot(2, 1, 2);
hold on; grid on;
try
    if isa(loadData(i).data, 'Simulink.SimulationData.Dataset')
        sig = loadData(i).data.get(3); % ดึงตัวแปรที่ 2
        time = sig.Values.Time;
        val  = sig.Values.Data;
    else
        data = loadData(i).data;
        if size(data, 2) >= 3
            time = data(:, 1);
            val  = data(:, 3); % คอลัมน์ที่ 3
        end
    end
    plot(time, val, 'LineWidth', 1.5);
catch
    fprintf('ไฟล์ %s ไม่มีข้อมูลชุดที่ 2\n', loadData(i).name);
end
xlabel('Time (s)')
ylabel('Input (Volt)')
if(min(val) < 0)
    ylim([-15 15])
else 
    ylim([-2 15])
end

hold off;