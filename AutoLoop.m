ref_model_list = {'chrip', 'sine1hz', 'stair', 'ramp', 'step'};
folder_name = 'Ref Signal';
target_folder = 'Raw Signal';
samples = 3; % เอากี่ตัวอย่าง

if target_folder ~= ""
    if ~exist(target_folder, 'dir'), mkdir(target_folder); end
end 

for j = 1:length(ref_model_list)
    prefix_name =ref_model_list{j};
    ref_model = load(fullfile(folder_name, [prefix_name,'.mat']));
    ref_model = ref_model.data;
    
    ref_input_signal = ref_model.get("input signal").Values;
    stoptime = ref_input_signal.TimeInfo.End;
    
    
    % 1. สั่งรัน Simulation
    simIn = Simulink.SimulationInput('MotorXploer');
    
    for i = 1:samples
        simIn = simIn.setModelParameter('StopTime', '1');
        sim(simIn);
    
        simIn = simIn.setModelParameter('StopTime', num2str(stoptime));
        out = sim(simIn);
    
        % 2. เข้าถึง Dataset ที่เก็บสัญญาณทั้งหมดไว้
        data = out.logsout;
    
        saveFileName = prefix_name + " " + int2str(i) + ".mat";
        if target_folder ~= ""
            output_name = fullfile(target_folder, saveFileName);
        else
            output_name = fullfile(aveFileName);
        end 

        disp(output_name)
        % บันทึกตัวแปร allLogs ลงในไฟล์ชื่อ simulation_r  esults.mat
        save(output_name, 'data');
        disp("done")

        % fprintf('บันทึกข้อมูลครั้งที่ ' + int2str(i) + ' ลงไฟล์ ' + saveFileName + 'เรียบร้อยแล้ว\n');
    end 
end