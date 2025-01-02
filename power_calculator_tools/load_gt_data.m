function GtData = load_gt_data(varargin)
    
    % Create an input parser
    p = inputParser;

    addParameter(p, 'directory', './power_calculator_results/gt_data/', @ischar); % Default: 'default'

    %% Get GT data files from directory 
    parse(p, varargin{:});
    gt_dir = p.Results.directory;

    % Get a list of all .mat files in the directory
    gt_files = {dir(fullfile(gt_dir, '*.mat')).name};
    
    %% Define struct and store data
    GtData = struct;
    for i_f = 1:length(gt_files)
        gt_file_name = gt_files{i_f};
        
        gt_absolute_file = [gt_dir, gt_file_name];
        % small gt data means a single file - struct is the combination
        gt_data = load(gt_absolute_file);
        gt_data = gt_data.results;
        meta_data = gt_data.study_info;
 
        query_cell = gt_query_cell_generator(meta_data);        

        GtData = setfield(GtData, query_cell{:}, gt_data);
    end

end
