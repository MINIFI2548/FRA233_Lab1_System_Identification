stoptime = 18;
prefixName = "est";
repeat = 3;

% 1. สั่งรัน Simulation
simIn = Simulink.SimulationInput('MotorXploer');

for i = 1:repeat
    simIn = simIn.setModelParameter('StopTime', num2str(stoptime));
    out = sim(simIn);
    
    % 2. เข้าถึง Dataset ที่เก็บสัญญาณทั้งหมดไว้
    allLogs = out.logsout;
    
    saveFileName = prefixName + int2str(i) + ".mat";
    disp(saveFileName)
    % บันทึกตัวแปร allLogs ลงในไฟล์ชื่อ simulation_results.mat
    save(saveFileName, 'allLogs');
    disp("done")
    % fprintf('บันทึกข้อมูลครั้งที่ ' + int2str(i) + ' ลงไฟล์ ' + saveFileName + 'เรียบร้อยแล้ว\n');

    simIn = simIn.setModelParameter('StopTime', '2');
    out = sim(simIn);
end 