% 1. โหลดข้อมูลจากไฟล์
load('stair 1.mat');

% เข้าถึง Dataset (ตรวจสอบชื่อตัวแปรใน Workspace ของคุณ ปกติจะเป็น ans)
ds = data; 

% ดึงข้อมูล Time Series ออกมา
input_ts = ds.get('input signal').Values;
motor_ts = ds.get('Motor Angular Velocity').Values;

t_in = input_ts.Time;
v_in = input_ts.Data;

t_m = motor_ts.Time;
v_m = motor_ts.Data;

% 2. หาจุดที่มีการเปลี่ยนแปลงของ Input (Step Changes)
% หาตำแหน่งที่ค่า Input เปลี่ยนจากค่าเดิม
rising_edge_indices = find(diff(v_in) > 0) + 1;

delays = []; % ตัวแปรเก็บค่าความต่างเวลาของแต่ละช่วง

% 3. วนลูปเพื่อหา Delay ในแต่ละการเปลี่ยนแปลง
fprintf('--- วิเคราะห์การเปลี่ยนแปลงแต่ละช่วง ---\n');

for i = 1:length(rising_edge_indices)
    idx_in = rising_edge_indices(i);
    t_start = t_in(idx_in);      % เวลาที่ Input เริ่มขยับขึ้น
    val_before = v_m(idx_in-1);  % ค่าความเร็วมอเตอร์ก่อนที่ Input จะขึ้น
    
    % 3. หาเวลาที่ Motor เริ่มตอบสนองหลังจาก t_start
    % ปรับ Threshold ตามความเหมาะสมของ Noise ในงานของคุณ
    threshold = 0.01; 
    idx_motor = find(t_m >= t_start & (v_m - val_before) > threshold, 1);
    
    if ~isempty(idx_motor)
        t_motor = t_m(idx_motor);
        delay = t_motor - t_start;
        delays = [delays; delay];
        
        fprintf('ลูกที่ %d (ขาขึ้น): Input เปลี่ยนที่ %.4f s, Motor ตอบสนองที่ %.4f s (Delay = %.6f s)\n', ...
            i, t_start, t_motor, delay);
    end
end

% 4. คำนวณค่าเฉลี่ย
if ~isempty(delays)
    avg_delay = mean(delays);
    std_delay = std(delays);
    
    fprintf('\n--- สรุปผลลัพธ์ ---\n');
    fprintf('จำนวนเหตุการณ์ที่ตรวจพบ: %d ครั้ง\n', length(delays));
    fprintf('ค่าเฉลี่ยความต่างเวลา (Average Delay): %.6f วินาที\n', avg_delay);
    fprintf('ค่าเบี่ยงเบนมาตรฐาน (Std Dev): %.6f วินาที\n', std_delay);
else
    fprintf('ไม่พบจุดการเปลี่ยนแปลงที่ชัดเจน\n');
end