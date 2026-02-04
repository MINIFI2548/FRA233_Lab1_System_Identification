%% --- 1. ตั้งค่าการเลือกไฟล์ ---
usePrefix = false; % เปลี่ยนเป็น true เพื่อใช้ Prefix / เปลี่ยนเป็น false เพื่อใช้ targetFiles

prefix = 'Ramp1-'; % กรณีใช้ Prefix
targetFiles = {'Ramp1-30HZ.mat', 'Ramp1-152HZ.mat', 'Ramp1-15152HZ.mat'}; 

labels = {};

% ตรวจสอบการเลือกไฟล์
if usePrefix
    filesInfo = dir([prefix, '*.mat']);
    fileList = {filesInfo.name};
else
    fileList = targetFiles;
end

numFiles = length(fileList);
if numFiles == 0
    error('ไม่พบไฟล์ที่ต้องการ');
end

%% --- 2. ตั้งค่าพารามิเตอร์ FFT ---
Fs = 1000;            % Sampling Frequency (ปรับตามข้อมูลจริง)
T = 1/Fs;             % Sampling period

figure('Name', 'Multi-FFT Analysis');
% ใช้ tiledlayout เพื่อจัดเรียงกราฟแนวตั้ง (หรือใช้ subplot(numFiles, 1, i))
t = tiledlayout(numFiles, 1, 'Padding', 'compact', 'TileSpacing', 'compact');

%% --- 3. ลูปโหลดข้อมูลและพล็อต FFT ---
for i = 1:numFiles
    filename = fileList{i};
    
    try
        % โหลดข้อมูล
        content = load(filename);
        
        % เข้าถึงข้อมูล (รองรับโครงสร้าง Simulink Dataset ตามไฟล์ตัวอย่าง)
        if isfield(content, 'data')
            ds = content.data;
            sig = ds.get(1); 
            d = sig.Values.Data;
        else
            % กรณีไฟล์ .mat ทั่วไปที่เก็บตัวแปร d ไว้โดยตรง
            d = content.d; 
        end
        
        % --- คำนวณ FFT (ตามสูตรที่คุณให้มา) ---
        L = length(d);
        Y = fft(d);
        f_axis = Fs/L * (-L/2 : L/2-1);
        mag_Y = abs(fftshift(Y));
        
        % --- พล็อตลงใน Subplot ---
        % nexttile;
        plot(f_axis, mag_Y, 'LineWidth', 2);
        hold on
        % ตั้งชื่อ Title โดยตัด Prefix ออกเพื่อความสะอาด
        [~, nameOnly, ~] = fileparts(filename);
        cleanLabel = strrep(nameOnly, prefix, '');
        title(['FFT Spectrum: ', cleanLabel]);
        
        grid on;
        ylabel('|fft(X)|');
        if i == numFiles
            xlabel('Frequency (Hz)');
        end
        % จัดการ Label: ตัด prefix และนามสกุลออก
        [~, nameOnly, ~] = fileparts(loadData(i).name);
        cleanLabel = strrep(nameOnly, prefix, ''); 
        labels{end+1} = cleanLabel;
    catch ME
        fprintf('เกิดข้อผิดพลาดกับไฟล์ %s: %s\n', filename, ME.message);
    end
end
legend(labels, 'Interpreter', 'none', 'Location', 'best');
title(t, 'Comparison of FFT Spectrums', 'FontSize', 14, 'FontWeight', 'bold');