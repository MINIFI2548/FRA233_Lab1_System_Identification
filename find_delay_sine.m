filename = 'Aligned_chrip-max.mat';

% 1. โหลดคลื่น Sine จากไฟล์
load(filename);
ds = data; % ตรวจสอบชื่อตัวแปรใน Workspace


motor_ts = ds.get('Motor Angular Velocity');
if isa(motor_ts, 'Simulink.SimulationData.Signal')
    motor_ts = motor_ts.Values;
end 

input_ts = ds.get('input signal');
if isa(input_ts, 'Simulink.SimulationData.Signal')
    input_ts = input_ts.Values;
end 

t = input_ts.Time;
v_in = input_ts.Data;
v_m = motor_ts.Data;

% --- วิธีที่ 1: Time Domain (Normalized) ---
figure('Name', 'Sine Wave Analysis');
subplot(2,1,1);
% ปรับสเกลให้เป็น 0-1 เพื่อเทียบรูปทรงคลื่นได้ชัดๆ
v_in_norm = (v_in - min(v_in)) / (max(v_in) - min(v_in));
v_m_norm = (v_m - min(v_m)) / (max(v_m) - min(v_m));

plot(t, v_in_norm, 'k--', 'LineWidth', 1.2); hold on;
plot(t, v_m_norm, 'r', 'LineWidth', 1.5);
title('Time Domain Comparison (Normalized Scale)');
legend('Input Signal', 'Motor Velocity');
grid on; xlabel('Time (s)');

% --- วิธีที่ 2: Lissajous Pattern (X-Y Plot) ---
subplot(2,1,2);
plot(v_in, v_m, 'b', 'LineWidth', 1.5);
title('Lissajous Pattern (X-Y Plot)');
xlabel('Input Signal Amplitude');
ylabel('Motor Velocity Amplitude');
grid on;
axis equal; % สำคัญมากเพื่อให้เห็นรูปร่างวงรีที่แท้จริง

% --- วิธีที่ 3: คำนวณความหน่วง (Delay Analysis) ---
% หาค่า Phase Shift โดยใช้ Cross-correlation
[corr, lags] = xcorr(v_m, v_in);
[~, I] = max(corr);
t_delay = lags(I) * mean(diff(t)); % แปลงจาก Lag เป็นวินาที

% คำนวณเฟส (สำหรับ 1Hz: 1 รอบ = 1 วินาที = 360 องศา)
freq = 1; % 1 Hz ตามชื่อไฟล์
phase_shift = t_delay * 360 * freq;

fprintf('\n--- ผลการวิเคราะห์ ');
fprintf(filename);
fprintf('\n');
fprintf('เวลาที่หน่วง (Time Delay): %.6f วินาที\n', abs(t_delay));
fprintf('ความต่างเฟส (Phase Shift): %.2f องศา\n', abs(phase_shift));
if abs(phase_shift) > 5
    fprintf('สถานะ: พบความหน่วงอย่างชัดเจน (กราฟ X-Y จะเป็นวงรี)\n');
else
    fprintf('สถานะ: ระบบตอบสนองได้เร็วมาก (กราฟ X-Y เกือบเป็นเส้นตรง)\n');
end