function [GtData, RepData] = load_rep_and_gt_results()

    vars = who;       % Get a list of all variable names in the workspace
    vars(strcmp(vars, 'RepData')) = [];  % Remove the variable you want to keep from the list
    vars(strcmp(vars, 'GtData')) = [];
    clear(vars{:});   % Clear all other variables
    clc;
    
    Params = setparams();

    %% Get rep data
    if ~exist('RepData', 'var')
        RepData = unite_results_from_directory('directory', Params.save_directory);
    else
        % disp('Data already loaded')
    end
    
    %% Get GT data
    if ~exist('GtData', 'var')
        GtData = load_gt_data('directory', Params.gt_data_dir);
    end
    
    %% Load gt data location in rep data
    RepData = l_dfs_add_gt_location(RepData, {}, RepData);
    
    %% TODO: Optimize this with dfs_struct 
    function RepData = l_dfs_add_gt_location(node, path_cell, RepData)
         
        fields = fieldnames(node);
        
        %% Loop over 
        for i = 1:numel(fields)
            field_name = fields{i};
            path_cell = [path_cell, {field_name}];
    
            %% Stopping condition?
            flag_meta = strcmp(field_name, 'meta_data');
            flag_brain = strcmp(field_name, 'brain_data');
            
            if ~flag_meta && ~flag_brain
                RepData = l_dfs_add_gt_location(node.(field_name), path_cell, RepData);
            elseif flag_meta
                RepData = add_gt_location_to_rep_data(path_cell, RepData);
            end
            path_cell = path_cell(1:end-1);
        end
    end

end





