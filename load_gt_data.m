function GtData = load_gt_data(varargin)
    
    % Create an input parser
    p = inputParser;

    addParameter(p, 'directory', './data_results/gt_data/', @ischar); % Default: 'default'

    %% Get GT data files from directory 
    parse(p, varargin{:});
    gt_dir = p.Results.directory;

    % Get a list of all .mat files in the directory
    gt_files = {dir(fullfile(gt_dir, '*.mat')).name};
    
    %% Define struct and store data
    GtData = struct;
    for i_f = 1:length(gt_files)
        gt_file_name = gt_files{i_f};
        
        [~, gt_file_name_no_ext, ~] = fileparts(gt_file_name);
        gt_cell = strsplit(gt_file_name_no_ext, '_');
    
        gt_task_cell = gt_cell(4:end);
        task_name = strjoin(gt_task_cell, '_');
        
        gt_data_set = gt_cell{1};
        gt_data_type = gt_cell{2};
        location_1 = strcat(gt_data_set, '_', gt_data_type);  

        file_path = fullfile(gt_dir, gt_file_name);
        GtData.(location_1).(task_name) = load(file_path);
        
    end

end
