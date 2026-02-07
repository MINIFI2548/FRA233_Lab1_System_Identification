file_name_list = {'chirp', 'ramp', 'sine', 'stair', 'step'};
for j = 1:length(file_name_list)
    figure_name = file_name_list{j};
    figure('Name', figure_name);
    load("Estimated\Estimated-" + file_name_list{j} + "-1.mat");

    file_name = "Shifted_Results\Aligned_" + file_name_list{j} + " 1.mat"
    data_struct = load(file_name);
    data = data_struct.data; 
            
    Time = data{1}.Time;
    Time = Time - min(Time);
    Raw_velocity = squeeze(double(data.get("Motor Angular Velocity").Data));
    Raw_input = squeeze(double(data.get("input signal").Data));
    
    % timeseries
    Raw_velocity_sig = timeseries(Raw_velocity, Time);
    Raw_input_sig    = timeseries(Raw_input, Time);
    
    % --- เตรียม Simulation ---
    simIn = Simulink.SimulationInput('Lab1_parameter_estimation_student');
    simIn = simIn.setModelParameter('StopTime', num2str(max(Time)));
    out = sim(simIn);
    
    Sim_velocity = out.logsout{1}.Values.Data;
    
    % --- Plotting ---
    subplot(2, 1, 1)
    plot(Time, Raw_velocity, 'LineWidth', 1.2, 'DisplayName', 'Measured')
    hold on
    plot(Time, Sim_velocity, 'LineWidth', 1.2, 'DisplayName', 'Simulated')
    grid on
    title_str = "Measured And Simulated";
    title(title_str, 'FontSize', 10)
    % แสดง Legend (ป้ายกำกับ)
    legend('Location', 'best')
    ylabel('Omega(Rad/s)')
    xlabel('Time(s)')
    if (min(Raw_input_sig) < -5)
        ylim([-300 300])
    else 
        ylim([-60, 300])
    end

    subplot(2, 1, 2)
    plot(Time, Raw_input, 'LineWidth', 1.2)
    grid on
    title_str = "Input Signal";
    title(title_str, 'FontSize', 10)
    ylabel('Volt')
    xlabel('Time(s)')
    grid on
    if (min(Raw_input_sig) < -5)
        ylim([-15 15])
    else 
        ylim([-2, 15])
    end
    sgtitle(upper(figure_name), 'FontSize', 16, 'FontWeight', 'bold');
end