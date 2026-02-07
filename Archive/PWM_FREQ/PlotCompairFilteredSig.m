titleName = 'Filtered Signal Comparison';
% --- 1. ตั้งค่าการเลือกไฟล์และฟิลเตอร์ ---
usePrefix = false; 
targetFiles = {'Ramp 30Hz-1.mat', 'Ramp 152Hz-1.mat', 'Ramp 7676Hz-1.mat'}; 
fs = 1000; 

lpFilt = designfilt('lowpassiir', 'PassbandFrequency', 1, ...
                    'StopbandFrequency', 25, 'SampleRate', fs);

% 2. โหลดข้อมูล
loadData = struct('name', {}, 'data', {});
hzLabels = {}; % สร้างลิสต์สำหรับเก็บชื่อเฉพาะ ...Hz

for i = 1:length(targetFiles)
    filename = targetFiles{i};
    if exist(filename, 'file') == 2
        content = load(filename);
        loadData(i).name = filename;
        if isfield(content, 'data'), loadData(i).data = content.data;
        else, vars = fields(content); loadData(i).data = content.(vars{1}); end
        
        % ดึงเฉพาะส่วนที่เป็น ...Hz ออกมาจากชื่อไฟล์
        labelHz = regexp(filename, '\d+Hz', 'match', 'once');
        hzLabels{end+1} = labelHz; 
    end
end

figure('Color', 'w', 'Position', [100, 100, 1000, 850]);

% --- ลูปสำหรับพล็อตทุกสัญญาณ ---
for i = 1:length(loadData)
    if isempty(loadData(i).data), continue; end
    
    % เตรียมข้อมูล
    if isa(loadData(i).data, 'Simulink.SimulationData.Dataset')
        s1 = loadData(i).data.get(1); t1 = s1.Values.Time; v1 = s1.Values.Data;
        s2 = loadData(i).data.get(2); t2 = s2.Values.Time; v2 = s2.Values.Data;
        s3 = loadData(i).data.get(3); t3 = s3.Values.Time; v3 = s3.Values.Data;
    else
        data = loadData(i).data;
        t1 = data(:,1); v1 = data(:,2); % Omega
        t2 = data(:,1); v2 = data(:,3); % Current
        t3 = data(:,1); v3 = data(:,4); % Input
    end

    % --- Subplot 1: Omega (Filtered) ---
    subplot(3, 1, 1); hold on; grid on;
    v1_f = filtfilt(lpFilt, v1);
    plot(t1, v1_f, 'LineWidth', 1.5);
    ylabel('Omega (Rad/s)');

    % --- Subplot 2: Current (Filtered) --- (แถวกลางตามที่ต้องการ)
    subplot(3, 1, 2); hold on; grid on;
    v2_f = filtfilt(lpFilt, v2);
    % plot(t2, v2, 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5); % ปิดไว้ตามโค้ดที่คุณส่งมา
    plot(t2, v2_f, 'LineWidth', 1.5); 
    ylabel('Current (A)');
    title('Current (Filtered)');

    % --- Subplot 3: Input Signal ---
    subplot(3, 1, 3); hold on; grid on;
    plot(t3, v3, 'LineWidth', 1.5);
    ylabel('Dutycycle (%)');
    xlabel('Time (s)');
end

% --- ตั้งค่าหัวข้อใหญ่และ Legend ---
subplot(3, 1, 1);
legend(hzLabels, 'Location', 'best'); % ใช้เฉพาะชื่อ ...Hz ที่ดึงมา

sgtitle(titleName, 'FontSize', 18, 'FontWeight', 'bold');