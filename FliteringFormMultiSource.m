%% --- 1. ตั้งค่าการเลือกไฟล์และฟิลเตอร์ ---
usePrefix = false; % true = ใช้ Prefix, false = ใช้รายชื่อใน targetFiles
prefix = 'Ramp1-'; 
targetFiles = {'Ramp1-30HZ.mat', 'Ramp1-152HZ.mat', 'Ramp1-15152HZ.mat'}; 

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

%% --- 2. เตรียม Figure และ Subplots (2 กราฟแนวตั้ง) ---
figure('Name', 'Filtering Comparison Across All Sources');
t_layout = tiledlayout(2, 1, 'Padding', 'compact', 'TileSpacing', 'loose');

% สร้าง Axes รอไว้สำหรับ 2 กราฟ
ax1 = nexttile; hold(ax1, 'on'); grid(ax1, 'on');
title(ax1, 'Zero-Phase Filtering (filtfilt) - All Sources');
ylabel(ax1, 'Amplitude');

ax2 = nexttile; hold(ax2, 'on'); grid(ax2, 'on');
title(ax2, 'Conventional Filtering (filter) - All Sources');
ylabel(ax2, 'Amplitude');
xlabel(ax2, 'Time (s)');

%% --- 3. ลูปประมวลผลทุกไฟล์และพล็อต ---
for i = 1:numFiles
    filename = fileList{i};
    
    try
        % โหลดข้อมูล
        content = load(filename);
        
        % ดึงข้อมูล (รองรับโครงสร้าง Simulink Dataset)
        if isfield(content, 'data')
            ds = content.data;
            % ตรวจสอบว่าเป็น Dataset หรือ Cell
            if isa(ds, 'Simulink.SimulationData.Dataset')
                sig = ds.get(1);
            else
                sig = ds{1};
            end
            
            y = sig.Values.Data;
            t = (0:length(y)-1)/fs; % หรือใช้ sig.Values.Time ถ้ามี
            
            % ประมวลผล Filter
            y_filtfilt = filtfilt(lpFilt, y);
            y_filter   = filter(lpFilt, y);
            
            % จัดการชื่อ Label (ตัด Prefix และนามสกุลออก)
            [~, nameOnly, ~] = fileparts(filename);
            cleanLabel = strrep(nameOnly, prefix, '');
            labels{end+1} = cleanLabel;
            
            % พล็อตลงในกราฟที่ 1 (filtfilt)
            plot(ax1, t, y_filtfilt, 'LineWidth', 1.5);
            
            % พล็อตลงในกราฟที่ 2 (filter)
            plot(ax2, t, y_filter, 'LineWidth', 1.5);
            
        end
    catch ME
        fprintf('Error processing %s: %s\n', filename, ME.message);
    end
end

%% --- 4. ใส่ Legend ให้ทั้ง 2 กราฟ ---
if ~isempty(labels)
    legend(ax1, labels, 'Interpreter', 'none', 'Location', 'eastoutside');
    legend(ax2, labels, 'Interpreter', 'none', 'Location', 'eastoutside');
end

% เชื่อมแกน X ให้ซูมไปพร้อมกัน (Optional)
linkaxes([ax1, ax2], 'x');