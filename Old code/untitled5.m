hzList = [30, 152, 15152];
figure; % สร้างหน้าต่างกราฟใหม่
hold on;

% ตัวแปรสำหรับเก็บ Graphic Objects เพื่อทำ Legend
p_omega = []; 

for hzIndex = 1:length(hzList)
    currentHz = hzList(hzIndex);
    filename = "Ramp " + string(currentHz) + "Hz-1.mat";
    
    try
        content = load(filename);
        
        % ตรวจสอบโครงสร้างข้อมูล
        if isfield(content, 'data')
            ds = content.data;
            if isa(ds, 'Simulink.SimulationData.Dataset')
                sig = ds.get(1); % Omega
                sigInput = ds.get(3); % Current/Input
                time = sig.Values.Time;
                val = sig.Values.Data;
                inputVal = sigInput.Values.Data * (100/12);
            else
                time = ds(:, 1);
                val = ds(:, 2);
                inputVal = ds(:, 3) * (100/12);
            end
            
            % --- พล็อตแกนซ้าย (Omega) ---
            yyaxis left
            % เก็บค่า plot ลงในตัวแปร p เพื่อระบุชื่อใน Legend
            p = plot(time, val, 'LineWidth', 1.2, 'DisplayName', string(currentHz) + " Hz");
            p_omega = [p_omega, p]; 
            
            % --- พล็อตแกนขวา (Duty Cycle) ---
            % หมายเหตุ: หาก Input เหมือนกันทุกไฟล์ อาจจะพล็อตแค่เส้นเดียวเพื่อไม่ให้รก
            yyaxis right
            plot(time, inputVal, 'r' , 'HandleVisibility', 'off'); 
        end
        
    catch
        warning("Could not find or read: " + filename);
    end
end

% --- ตกแต่งกราฟ ---
yyaxis left
ylabel('Omega (Rad/s)');
ax = gca; 
ax.YColor = [0 0.4470 0.7410];
% ปรับ Limit แกนซ้ายให้ครอบคลุมข้อมูลทั้งหมด
ylim auto; 

yyaxis right
ylabel('Duty Cycle (%)');
ax.YColor = [0.8500 0.3250 0.0980];
ylim([-10 110]);

xlabel('Time (s)');
title('Comparison of Motor Speed (Omega) at Different Frequencies');
grid on;

% แสดง Legend เฉพาะของฝั่ง Omega (ความถี่ต่างๆ)
legend(p_omega, 'Location', 'northeastoutside');

hold off;