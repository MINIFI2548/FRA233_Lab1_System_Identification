raw_signal_prefix_list = {'chirp', 'sine', 'slop1', 'stair', 'step'};

figure_name = "Compair modle " + model_name + " with each raw signal";
figure('Name', figure_name);
total_rmse = 0;
for j = 1:5
    raw_signal_prefix = raw_signal_prefix_list{j};
    for i = 1:3
        raw_signal_name = raw_signal_prefix + "-" + int2str(i);
        % load data
        data = load("EACH SIGNAL DATA -1\" + raw_signal_name + ".mat");
        data = data.data;
        
        Time = data{1}.Values.Time;
        Raw_velocity = squeeze(double(data{1}.Values.Data));
        Raw_input    = squeeze(double(data{2}.Values.Data));
        
        % timeseries
        Raw_velocity_sig = timeseries(Raw_velocity, Time);
        Raw_input_sig    = timeseries(Raw_input, Time);
        
        % simulink
        simIn = Simulink.SimulationInput('Lab1_parameter_estimation_student');
        simIn = simIn.setModelParameter('StopTime', num2str(Time(end)));
        out = sim(simIn);
        
        Sim_velocity = out.logsout{1}.Values.Data;
        
        % คำนวณ MAPE (Mean Absolute Percentage Error)
        % หมายเหตุ: หาก actual มีค่าเป็น 0 ต้องระวังการหารด้วยศูนย์
        idx = abs(Raw_velocity) > 1e-3; 
        if any(idx)
            mape_val = mean(abs((Raw_velocity(idx) - Sim_velocity(idx)) ./ Raw_velocity(idx))) * 100;
        else
            mape_val = NaN; % ป้องกันกรณีไม่มีข้อมูลเลย
        end
        
        % คำนวณ RMSE (Root Mean Square Error)
        rmse_val = sqrt(mean((Raw_velocity - Sim_velocity).^2));
        
        % ===== top row : velocity =====
        nexttile(j + ((i - 1)*5))
        plot(Time, Raw_velocity, 'LineWidth', 1.2)
        hold on
        plot(Time, Sim_velocity, 'LineWidth', 1.2)
        hold off
        grid on
        % title(model_show_name + ' - ' + signal_name_list{i})
        % แสดงค่า RMSE และ MAPE ไว้ที่ Title หรือ Text บนกราฟ
        % ใช้ newline เพื่อขึ้นบรรทัดใหม่ใน title
        title_str = { ("model " + model_name + " - " + raw_signal_name), ...
                      sprintf('RMSE: %.3f', rmse_val) };
        title(title_str, 'FontSize', 9)
        ylabel('Omega(Rad/s)')
        % if i == nSig
            legend('Measured','Simulated','Location','best')
        % end
        total_rmse = total_rmse + rmse_val;
        xlabel('Time (s)')
    end 
end 
paramText = sprintf([ ...
'Motor Parameters\n' ...
'B   = %.4e\n' ...
'Eff = %.5f\n' ...
'J   = %.4e\n' ...
'K_e = %.5f\n' ...
'R_m = %.2f\n' ...
'L_m = %.5f\n' ...
'total RMSE = %.2f'], ...
motor_B, motor_Eff, motor_J, motor_Ke, 2.97, 36.22e-3, total_rmse);
tb = annotation('textbox', ...
           'String', paramText, ...
           'FitBoxToText', 'on', ...
           'BackgroundColor', 'white', ...
           'EdgeColor', [0.3 0.3 0.3], ...
           'FontSize', 11, ...
           'FontName', 'Consolas');

tb.Units = 'normalized';
tb.Position(1) = 1 - tb.Position(3) - 0.001;  % เว้นขอบขวา
tb.Position(2) = 1 - tb.Position(4) - 0.15;  % เว้นขอบบน