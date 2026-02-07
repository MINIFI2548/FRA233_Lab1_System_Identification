% %% --- ตั้งค่าการเลือกไฟล์ ---
% titleName = 'Filtered Signal Comparison';
% prefix = 'Ramp 30Hz'; 
% targetFiles = {'Ramp1-30HZ(5t).mat', 'Ramp1-152HZ(1t).mat', 'Ramp1-15152HZ(0.01t).mat'}; 
% 
% % ตรวจสอบการเลือกไฟล์
% if usePrefix
%     filesInfo = dir([prefix, '*.mat']);
%     fileList = {filesInfo.name};
% else
%     fileList = targetFiles;
% end
% compairSignalSamePWMFreq

hzList = {30, 38, 51, 78, 152, 303, 606, 1166, 2165, 3788, 7676, 15152};
% hzList = {30, 38}; 
usePrefix = true; 

for haIndex = 1:length(hzList)
    % 1. ใช้ {} เพื่อดึงค่าตัวเลขออกจาก Cell
    currentHz = hzList{haIndex}; 
    
    % 2. สร้าง String สำหรับชื่อไฟล์และ Title
    % ใช้ string() ครอบเพื่อให้บวกกันได้ง่าย (MATLAB ยุคใหม่)
    hzLable = string(currentHz) + "Hz"; 
    prefix = "Ramp " + hzLable;
    titleName = "Signal Comparison " + prefix;

    compairSignalSamePWMFreq
end