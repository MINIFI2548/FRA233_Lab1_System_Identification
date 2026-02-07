if usePrefix
    filesInfo = dir(prefix + '*.mat');
    fileList = {filesInfo.name};
else
    fileList = targetFiles;
end

% ตั้งค่า Filter
fs = 1000; % Sampling Frequency
lpFilt = designfilt('lowpassiir', 'PassbandFrequency', 1, ...
                    'StopbandFrequency', 25, 'SampleRate', fs);

numFiles = length(fileList);
if numFiles == 0
    error('ไม่พบไฟล์ที่ต้องการ');
end

figure('Name', titleName); % สร้าง Figure หลักเพียงอันเดียว

%% --- ลูปโหลดข้อมูลและพล็อตแยก Subplot ---
for i = 1:numFiles 
    filename = fileList{i};
    try 
        % โหลดข้อมูล
        content = load(filename);
        
        % เลือกพื้นที่กราฟ (แถวที่ i, ทั้งหมด 1 คอลัมน์)
        subplot(numFiles, 1, i); 
        % เข้าถึงข้อมูล
        if isfield(content, 'data')
            ds = content.data;
            if isa(ds, 'Simulink.SimulationData.Dataset')
                sig = ds.get(1); % ดึงสัญญาณหลัก (Omega)
                time = sig.Values.Time;
                val  = sig.Values.Data;
            else
                % กรณีเป็น matrix ธรรมดาที่อยู่ในฟิลด์ data
                time = ds(:, 1);
                val  = ds(:, 2);
            end
        else
            % กรณี load มาแล้วเป็นตัวแปร data โดยตรง
            data = content.data; 
            time = data(:, 1);
            val  = data(:, 2);
        end
        
        % --- ประมวลผล Filter ---
        val_filt = filtfilt(lpFilt, val);

        % --- พล็อตเปรียบเทียบในกราฟเดียวกัน ---
        hold on
        plot(time, val, 'LineWidth', 0.5); % Raw Data (สีเทา เส้นบาง)
        % plot(time, val_filt, 'LineWidth', 1.5); % Filtered (สีส้ม/แดง เส้นหนา)
        legend('Raw Signal', 'Filtered Signal', 'Location', 'northeast');
        % --- ตกแต่ง Subplot ---
        [~, nameOnly, ~] = fileparts(filename);
        title([strrep(nameOnly, '_', '\_')]);
        ylabel('Omega (Rad/s)');
        xlabel('Time (s)');
        grid on;
    catch ME
        fprintf('เกิดข้อผิดพลาดกับไฟล์ %s: %s\n', filename, ME.message);
    end
end
% --- 2. พล็อต Input Signal (Current) ไว้แถวล่างสุดของชุดนี้ ---
% กรณีต้องการให้โชว์ Input ของไฟล์สุดท้าย หรือแยกกราฟต่างหาก
% ในตัวอย่างนี้จะพล็อต Input ไว้ที่ subplot แถวสุดท้าย
subplot(numFiles + 1, 1, numFiles + 1);
sigInput = ds.get(3); % ดึง Current (Signal 2)
plot(time, sigInput.Values.Data * (100/12) , 'r', 'LineWidth', 1.5);
title('PWM INPUT');
ylabel('dutycycle(%)');
xlabel('Time (s)');
ylim([-20 130])
grid on;
% ปรับระยะห่างระหว่างกราฟให้สวยงาม
sgtitle('Comparison of Signals at Identical Frequency'); % หัวข้อใหญ่ด้านบนสุด