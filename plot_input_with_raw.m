filename = "chrip-max.mat"; 
content = load(filename);
data = content.data; 

Time = data{1}.Values.Time;
Raw_velocity = squeeze(double(data.get('Motor Angular Velocity').Values.Data));
Raw_input    = squeeze(double(data.get('input signal').Values.Data));

% --- ส่วนการประมวลผล ---
max_v = max(abs(Raw_velocity));
max_i = max(abs(Raw_input));
Scaled_input = Raw_input * (max_v / max_i); % ขยายสัญญาณ input

% --- ส่วนการ Plot กราฟ ---
figure('Color', 'w'); % สร้าง Window กราฟพื้นหลังสีขาว
hold on; 
grid on;

% ใช้แกนซ้ายสำหรับ Velocity
yyaxis left
p1 = plot(Time, Raw_velocity, 'LineWidth', 1.5);
ylabel('Velocity (m/s)', 'FontSize', 12, 'FontWeight', 'bold');
title(['Comparison of Velocity and Scaled Input (File: ', filename, ')'], 'FontSize', 14);
ylim([-(300*(15/15)) 300])

% ใช้แกนขวาสำหรับ Input (แสดงทั้งแบบ Original และ Scaled เพื่อเปรียบเทียบ)
yyaxis right
p2 = plot(Time, Raw_input, 'LineWidth', 1.2); % สัญญาณที่ขยายแล้ว
ylabel('Input (Volt)', 'FontSize', 12, 'FontWeight', 'bold');
ylim([-15 15])

% ใส่รายละเอียดเพิ่มเติม
xlabel('Time (s)', 'FontSize', 12);
legend([p1, p2], {'Raw Velocity', 'Scaled Input'}, 'Location', 'northeast');

% ปรับสีแกนให้ดูง่าย (Optional)
ax = gca;
ax.YAxis(1).Color = p1.Color;
ax.YAxis(2).Color = p2.Color;