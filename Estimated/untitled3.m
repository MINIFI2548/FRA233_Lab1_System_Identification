% รายชื่อไฟล์ในโฟลเดอร์ Test Signal (อ้างอิงจากรูปภาพ)
raw_signal_list = {'chirp', 'ramp', 'sine', 'stair', 'step'};

% --- จัดการชื่อสำหรับ sgtitle ---
% เปลี่ยน "-" เป็น " " (Space)
% formatted_name = strrep(model_name, "-", " ");
% เปลี่ยนตัวแรกเป็นพิมพ์ใหญ่ (Capitalize first letter)
% formatted_name = regexprep(formatted_name, '(^.)', '${upper($1)}');
% figure_main_title = "Model " + formatted_name;

% tiledlayout(3, 5); % จัดเรียง 3 แถว (i) 5 คอลัมน์ (j)
% figure_name = "Test Signals";
% figure('Name', figure_name);
for j = 1:length(raw_signal_list)
    raw_file_name = raw_signal_list{j};
    figure_name = "Test Signal : " + raw_file_name;
    figure('Name', figure_name);


    % ในภาพไม่มีเลขต่อท้ายในโฟลเดอร์ Test Signal? 
    % ถ้าต้องการเทียบกับ Raw ต้นฉบับ ให้เลือกใช้ Chirp.mat, Ramp.mat ตรงๆ
    % แต่ถ้าต้องการไฟล์ที่มีเลข 1-3 ต้องแก้ Path ตรงนี้ครับ
    raw_file_name = raw_signal_list{j};
    % โหลด Raw Signal จากโฟลเดอร์ Test Signal
    % หมายเหตุ: ผมใช้ชื่อตาม raw_signal_list เพราะในโฟลเดอร์ย่อยไม่มีเลข 1-3
    data_struct = load("Test Signal\" + raw_file_name + ".mat");
    
    % สมมติว่าโครงสร้างไฟล์เหมือนเดิม (data{1} คือ Velocity, data{2} คือ Input)
    data = data_struct.data; 
    
    Time = data{1}.Time;
    Time = Time - min(Time);
    Raw_velocity = squeeze(double(data.get("Motor Angular Velocity").Data));
    Raw_input = squeeze(double(data.get("input signal").Data));
    
    % timeseries
    Raw_velocity_sig = timeseries(Raw_velocity, Time);
    Raw_input_sig    = timeseries(Raw_input, Time);
    
    % --- Plotting ---
    % subplot(5, 1, j)
    % plot(Time, Raw_velocity, 'LineWidth', 1.2, 'DisplayName', 'Measured')
    hold on
    plot(Time, Raw_input, 'LineWidth', 1.2)
    grid on
    
    % title_str = upper(raw_file_name);
    % title(title_str, 'FontSize', 10)
    % 
    % title_str = {raw_file_name, sprintf('RMSE: %.3f', rmse_val) };
    % title(title_str, 'FontSize', 8)
    if (min(Raw_input_sig) < -5)
        ylim([-15 15])
    else 
        ylim([-2, 15])
    end 
    % แสดง Legend (ป้ายกำกับ)
    % legend('Location', 'best')
    ylabel('Volt')
    xlabel('Time(s)')
    sgtitle(figure_name, 'FontSize', 16, 'FontWeight', 'bold');
end 