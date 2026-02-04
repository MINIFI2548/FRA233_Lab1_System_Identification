model_name = "stair-3" + ...
    "";
model_show_name = "Model form Chirp";

raw_signal_name_list_all = { {"step-1", "stair-1", "slop1-1"}, 
                             {"chirp-1", "sine-1"}};
signal_name_list_all = { {"Step", "Stair", "Slop"}, 
                         {"Chirp", "Sine"}};

for j = 1:length(raw_signal_name_list_all)
    raw_signal_name_list = raw_signal_name_list_all{j};
    signal_name_list = signal_name_list_all{j};
    nSig = length(raw_signal_name_list);
    
    % load Estimated Value
    SDOSessionData = load("Estimated\Estimated_" + model_name + ".mat");
    SDOSessionData = SDOSessionData.SDOSessionData;
    loadEstimatedValue
    
    figure_name = model_show_name + " - " + int2str(j);
    % figure('Name','Velocity (top) and Input (bottom)')
    % figure('Name', model_show_name + " - " + int2str(j));
    figure('Name', figure_name);
    
    tiledlayout(2, nSig, 'TileSpacing','compact', 'Padding','compact')
    
    for i = 1:nSig
    
        raw_signal_name = raw_signal_name_list{i};
    
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
        Sim_velocity = out.model.Data;
        
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
        nexttile(i)
        plot(Time, Raw_velocity, 'LineWidth', 1.2)
        hold on
        plot(Time, Sim_velocity, 'LineWidth', 1.2)
        hold off
        grid on
        % title(model_show_name + ' - ' + signal_name_list{i})
        % แสดงค่า RMSE และ MAPE ไว้ที่ Title หรือ Text บนกราฟ
        % ใช้ newline เพื่อขึ้นบรรทัดใหม่ใน title
        title_str = { (model_show_name + " - " + signal_name_list{i}), ...
                      sprintf('RMSE: %.3f, MAPE: %.2f%%', rmse_val, mape_val) };
        title(title_str, 'FontSize', 9)
        ylabel('Omega(Rad/s)')
        % if i == nSig
            legend('Measured','Simulated','Location','best')
        % end
        xlabel('Time (s)')
    
        % ===== bottom row : input =====
        nexttile(nSig + i)
        plot(Time, Raw_input, 'LineWidth', 1.2)
        grid on
        ylabel('Input')
        if(min(Raw_input_sig) < 0)
            ylim([-15 15])
        else 
            ylim([-2 15])
        end
        xlabel('Time (s)')
    
    end
    paramText = sprintf([ ...
    'Motor Parameters\n' ...
    'B   = %.4e\n' ...
    'Eff = %.5f\n' ...
    'J   = %.4e\n' ...
    'K_e = %.5f\n' ...
    'R_m = %.2f\n' ...
    'L_m = %.2f'], ...
    motor_B, motor_Eff, motor_J, motor_Ke, 2.97, 36.72);
    tb = annotation('textbox', ...
               'String', paramText, ...
               'FitBoxToText', 'on', ...
               'BackgroundColor', 'white', ...
               'EdgeColor', [0.3 0.3 0.3], ...
               'FontSize', 11, ...
               'FontName', 'Consolas');

    tb.Units = 'normalized';
    tb.Position(1) = 1 - tb.Position(3) - 0.001;  % เว้นขอบขวา
    tb.Position(2) = 1 - tb.Position(4) - 0.3;  % เว้นขอบบน
    % exportgraphics(gcf, figure_name + '.pdf', 'ContentType', 'vector');
end