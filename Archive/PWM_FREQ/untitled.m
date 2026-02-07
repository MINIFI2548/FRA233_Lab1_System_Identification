% --- MATLAB Script: Current Signal Comparison with Main Title ---

titleName = 'Current Load'; % ชื่อหัวข้อใหญ่
targetFiles = {'Ramp 30Hz-2.mat', 'Ramp 152Hz-4.mat', 'Ramp 7676Hz-1.mat'};
fs = 1000; 

lpFilt = designfilt('lowpassiir', 'PassbandFrequency', 1, ...
    'StopbandFrequency', 25, 'SampleRate', fs);

figure('Color', 'w', 'Position', [100, 100, 1500, 500]); % เพิ่มความสูงนิดหน่อยเพื่อให้มีที่ว่างสำหรับหัวข้อ

for i = 1:length(targetFiles)
    filename = targetFiles{i};
    try
        content = load(filename);
        if isfield(content, 'data'), dataObj = content.data;
        else, vars = fields(content); dataObj = content.(vars{1}); end
        
        if isa(dataObj, 'Simulink.SimulationData.Dataset')
            sig = dataObj.get(2); time = sig.Values.Time; val_raw = sig.Values.Data;
        else
            time = dataObj(:, 1); val_raw = dataObj(:, 3);
        end
        
        val_filtered = filtfilt(lpFilt, val_raw);
        
        subplot(1, 3, i);
        hold on; grid on;
        % plot(time, val_raw, 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
        plot(time, val_filtered, 'b', 'LineWidth', 1.2);
        
        freq_str = regexp(filename, '\d+Hz', 'match', 'once');
        title(['Current ', freq_str]);
        xlabel('Time (s)');
        if i == 1, ylabel('Current (A)'); end
    catch
    end
end

% --- เพิ่มหัวข้อใหญ่ตรงนี้ ---
sgtitle(titleName, 'FontSize', 20, 'FontWeight', 'bold');