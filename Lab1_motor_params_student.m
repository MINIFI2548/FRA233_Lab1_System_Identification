%{  
This script for prepare data and parameters for parameter estimator.
1. Load your collected data to MATLAB workspace.
2. Run this script.
3. Follow parameter estimator instruction.
%}
raw_signal_name = "Aligned_chirp 3";
full_path = "Shifted_Results\" + raw_signal_name + ".mat";
data = load(full_path);
data = data.data;
% R and L from  
motor_R = 3.74;
motor_L = 3272.36e-6;
% Optimization's parameters
motor_Eff = 0.5;
motor_Ke = 0.05;
motor_J = 1;
motor_B = 1;

% Extract collected data
if isa(data, 'Simulink.SimulationData.Dataset')
    Time = data.get('input signal').Time;
    Input =  data.get('input signal').Data;
    Input = squeeze(Input);
    Raw_input_sig = timeseries(Input, Time);
    Velo = double(data.get('Motor Angular Velocity').Data);
else
    Time = data.get('input signal').Values.Time;
    Input =  data.get('input signal').Values.Data;
    Input = squeeze(Input);
    Raw_input_sig = timeseries(Input, Time);
    Velo = double(data.get('Motor Angular Velocity').Values.Data);
end 


% Plot 
grid on
figure(Name='Motor velocity response')
plot(Time,Velo,Time,Input)
% plot(Time, Velo)