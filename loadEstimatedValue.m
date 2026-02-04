Estimated_data = SDOSessionData.Data.Workspace.LocalWorkspace.Exp.Parameters;

motor_B = Estimated_data(1).Value;
motor_Eff = Estimated_data(2).Value;
motor_Ke = Estimated_data(3).Value;
motor_J = Estimated_data(4).Value;

motor_R = 2.97;
motor_L = 36.22;

for i = 1:4 
    name = Estimated_data(i).Name; 
    switch name 
        case 'motor_B'
            motor_B = Estimated_data(i).Value;
        case 'motor_Eff'
            motor_Eff = Estimated_data(i).Value;
        case 'motor_J'
            motor_J = Estimated_data(i).Value;
        case 'motor_Ke'
            motor_Ke = Estimated_data(i).Value;
        otherwise
            disp("error")
    end
end