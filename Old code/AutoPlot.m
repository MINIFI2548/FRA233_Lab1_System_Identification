model_name = "stair-2";
raw_signal_name_list = {"step-1", "stair-1", "sine-1"};
fs = 1000;

raw_signal_name = "stair-2";
% load Estimated Value
SDOSessionData = load("Estimated\Estimated_" + model_name + ".mat");
SDOSessionData = SDOSessionData.SDOSessionData;
loadEstimatedValue

data = load("EACH SIGNAL DATA -1\" + raw_signal_name + ".mat");
% data = load(raw_signal_name + ".mat");
data = data.data;

Time = data{1}.Values.Time;
Raw_velocity = double(data{1}.Values.Data);
% Raw_input = double(data{2}.Values.Data);
Raw_input = squeeze(double(data{2}.Values.Data));

Raw_velocity_sig = timeseries(Raw_velocity, Time);
Raw_input_sig = timeseries(Raw_input, Time);
Amp_input = Raw_input * 20;

stoptime =  num2str((length(Time) - 1) / 1000);
simIn = Simulink.SimulationInput('Lab1_parameter_estimation_student');
simIn = simIn.setModelParameter('StopTime', stoptime);
out = sim(simIn);
outForPlot = out.model.Data;

figure(Name='Motor velocity response')
plot(Time,Raw_velocity,Time,Raw_input, Time, outForPlot)
% plot(Time, Raw_velocity, Time, Amp_input)
grid on

