% 1. กำหนดชื่อ Folder ที่ต้องการบันทึก
folderName = 'Test Signal';

% ถ้ายังไม่มี Folder นี้ ให้สร้างขึ้นมาใหม่
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

% 2. ค้นหา Figure ทั้งหมด
figs = findall(0, 'Type', 'figure');

% 3. วนลูปเพื่อบันทึกไฟล์
for k = 1:length(figs)
    % ดึงชื่อของ Figure มาใช้ (ถ้าไม่ได้ตั้งชื่อไว้จะเป็นค่าว่าง)
    figName = figs(k).Name;
    
    % กรณีที่ Figure ไม่มีชื่อ (Name เป็นค่าว่าง) ให้ใช้เลข Figure แทนเพื่อป้องกันไฟล์ไม่มีชื่อ
    if isempty(figName)
        figName = sprintf('Figure_%d', figs(k).Number);
    end
    
    % จัดการลบตัวอักษรที่ระบบไฟล์อาจไม่รองรับ (เช่น / \ : * ? " < > |)
    figName = regexprep(figName, '[\\/:\*\?"<>|]', '_');
    
    % สร้าง path ของไฟล์: folder/ชื่อไฟล์.png
    filename = fullfile(folderName, [figName, '.png']);
    
    fprintf('กำลังบันทึกไฟล์: %s\n', filename);
    
    % บันทึกไฟล์ด้วยความละเอียด 300 DPI
    exportgraphics(figs(k), filename, 'Resolution', 300);
end

disp("--- บันทึกรูปภาพลง Folder '" + folderName + "' เรียบร้อยแล้ว! ---");