% figs = findall(0,'Type','figure');
% 
% for k = 1:length(figs)
%     disp(k)
%     exportgraphics(figs(k),'SIGNAL_INPUT.pdf','Append',true);
%     disp("done")
% end

% 1. ค้นหา Figure ทั้งหมด
figs = findall(0, 'Type', 'figure');

% 2. เรียงลำดับตามหมายเลข Figure (เพื่อให้ชื่อไฟล์ตรงกับเลขรูป)
[~, idx] = sort([figs.Number]);
figs = figs(idx);

% 3. วนลูปเพื่อบันทึกไฟล์แยกกัน
for k = 1:length(figs)
    % สร้างชื่อไฟล์แบบอัตโนมัติ เช่น Image_1.png, Image_2.png
    filename = sprintf('Sample_Rate_Problem_%d.png', k);

    fprintf('กำลังบันทึกไฟล์: %s\n', filename);

    % บันทึกเป็น PNG ด้วยความละเอียด 300 DPI (ชัดพิเศษ)
    exportgraphics(figs(k), filename, 'Resolution', 300);
end

disp("บันทึกรูปภาพทั้งหมดเรียบร้อยแล้ว!");