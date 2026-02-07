model_prefix_list = {'chirp', 'sine', 'slop1', 'stair', 'step'};

for l = 1:5 
    % model_prefix = "step";
    model_prefix = model_prefix_list{l};
    for k= 1:3 
        model_name = model_prefix + "-" + int2str(k);
        load("Estimated\Estimated-" + model_name + ".mat");
        
        compairModel2EachRawSingle
    end
end 