model_name = "stair-1";
load("Estimated\Estimated-" + model_name + ".mat");
raw_signal_name = model_name;

% load data
data = load("EACH SIGNAL DATA -1\" + raw_signal_name + ".mat");
data = data.data;
Time = data{1}.Values.Time;
Raw_velocity = squeeze(double(data{1}.Values.Data));
Raw_input    = squeeze(double(data{2}.Values.Data));

% timeseries (สำหรับ Simulink)
Raw_velocity_sig = timeseries(Raw_velocity, Time);
Raw_input_sig    = timeseries(Raw_input, Time);

% simulink
simIn = Simulink.SimulationInput('Lab1_parameter_estimation_student');
simIn = simIn.setModelParameter('StopTime', num2str(Time(end)));
out = sim(simIn);
Sim_velocity = out.logsout{1}.Values.Data;

% สร้าง Figure ใหม่
figure('Name', model_name, 'Color', 'w');

% ===== แถวที่ 1 (บน): Velocity Comparison =====
subplot(2, 1, 1); 
plot(Time, Raw_velocity, 'LineWidth', 1.2)
hold on
plot(Time, Sim_velocity, 'LineWidth', 1.2) % ใช้เส้นประเพื่อให้เห็นความต่าง
hold off
grid on
title_str = {"Model And Measured"};
title(title_str, 'FontSize', 10)
ylabel('Omega (Rad/s)')
legend('Measured','Simulated','Location','best')

% ===== แถวที่ 2 (ล่าง): PWM Input =====
subplot(2, 1, 2);
plot(Time, Raw_input, 'r', 'LineWidth', 1);
if(min(Raw_input_sig) < 0)
    ylim([-15 15])
else 
    ylim([-2 15])
end
xlabel('Time (s)')
title('Input Signal');
ylabel('Volt');
xlabel('Time (s)');
grid on;

idx = abs(Raw_velocity) > 1e-3; 
if any(idx)
    mape_val = mean(abs((Raw_velocity(idx) - Sim_velocity(idx)) ./ Raw_velocity(idx))) * 100;
else
    mape_val = NaN; % ป้องกันกรณีไม่มีข้อมูลเลย
end

% ===== ส่วนของ Annotation (ข้อมูลพารามิเตอร์) =====
paramText = sprintf([ ...
'Motor Parameters\n' ...
'B   = %.4e\n' ...
'Eff = %.5f\n' ...
'J   = %.4e\n' ...
'K_e = %.5f\n' ...
'R_m = %.2f\n' ...
'L_m = %.5f'], ...
motor_B, motor_Eff, motor_J, motor_Ke, 2.97, 36.22e-3);
tb = annotation('textbox', ...
           'String', paramText, ...
           'FitBoxToText', 'on', ...
           'BackgroundColor', 'white', ...
           'EdgeColor', [0.3 0.3 0.3], ...
           'FontSize', 11, ...
           'FontName', 'Consolas');

tb.Units = 'normalized';
% tb.Position(1) = 1 - tb.Position(3) - 0.10;  % เว้นขอบขวา
% tb.Position(2) = 1 - tb.Position(4) - 0.60;  % เว้นขอบบน
