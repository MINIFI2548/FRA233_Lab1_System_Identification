hzList = {30, 38, 51, 78, 152, 303, 606, 1166, 2165, 3788, 7676, 15152};
for hzIndex = 1:length(hzList)
    titlename = string(hzList(hzIndex)) + "Hz";
    filename = "Ramp " + titlename + "-1.mat";

    % เลือกตำแหน่งที่จะวาดกราฟ
    subplot(rows, cols, hzIndex);
    content = load(filename); 

    % เข้าถึงข้อมูล
    try
        content = load(filename); 
        
        if isfield(content, 'data')
            ds = content.data;
            if isa(ds, 'Simulink.SimulationData.Dataset')
                sig = ds.get(1); % Omega
                sigInput = ds.get(3); % Current/Input
                
                time = sig.Values.Time;
                val  = sig.Values.Data;
                inputVal = sigInput.Values.Data * (100/12);
            else
                time = ds(:, 1);
                val  = ds(:, 2);
                inputVal = ds(:, 3) * (100/12); % สมมติว่า input อยู่ column 3
            end
        end

        % --- เริ่มต้นการพล็อต ---
        % --- พล็อตแกนซ้าย (Omega) ---
        yyaxis left
        plot(time, val, 'LineWidth', 1.2);
        ylabel('Omega (Rad/s)');
        ax = gca; 
        ax.YColor = [0 0.4470 0.7410]; % สีน้ำเงิน
        xlabel('Time (s)');

        % --- พล็อตแกนขวา (Duty Cycle) ---
        yyaxis right
        plot(time, inputVal, 'r', 'LineWidth', 1);
        ylabel('Duty Cycle (%)');
        ax.YColor = [0.8500 0.3250 0.0980]; % สีแดง

        % กำหนดให้ทั้งสองแกนเริ่มที่ค่าเดียวกัน 
        yyaxis left;  ylim([min(0, max(val) - max(val)*1.2)  max(val)*1.2]);
        yyaxis right; ylim([-20 120]); % เผื่อที่ให้เห็น 100% ชัดๆ

        title(titlename);
        grid on;
        
    catch
        warning("Could not find or read: " + filename);
    end
end

sgtitle('Comparison of Signals at Identical Frequency'); % หัวข้อใหญ่ด้านบนสุด