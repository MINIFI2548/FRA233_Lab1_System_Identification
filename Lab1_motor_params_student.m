%{  
This script for prepare data and parameters for parameter estimator.
1. Load your collected data to MATLAB workspace.
2. Run this script.
3. Follow parameter estimator instruction.
%}

raw_signal_name = "stair-2";
data = load("EACH SIGNAL DATA -1\" + raw_signal_name + ".mat");
        data = data.data;
% R and L from  
motor_R = 2.97;
motor_L = 36.22e-3;
% Optimization's parameters
motor_Eff = 0.5;
motor_Ke = 0.05;
motor_J = 1;
motor_B = 1;

% Extract collected data
Time = data{1}.Values.Time;
Input =  data{2}.Values.Data;
Input = squeeze(Input);
Raw_input_sig = timeseries(Input, Time);
Velo = double(data{1}.Values.Data);

% Plot 
figure(Name='Motor velocity response')
plot(Time,Velo,Time,Input)
% plot(Time, Velo)