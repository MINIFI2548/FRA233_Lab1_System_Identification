mn_list = {'chirp-1-form-stepValue', 'ramp-1', 'sine-1', 'stair-1', 'step-1'};
shn_list = {'Chirp', 'Ramp', 'Sine', 'Stair' ,'Step'};

for w = 1:5
    model_name = mn_list(w);
    model_show_name = "Model form " + shn_list(w);
    AutoPlotV2 
end

% for k = 1:10
%     figure(k);
%     exportgraphics(gcf, 'all_figures.pdf-2', 'Append', true);
% end