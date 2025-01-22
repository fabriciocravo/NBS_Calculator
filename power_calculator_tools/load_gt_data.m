function GtData = load_gt_data(varargin)
    
    % Create an input parser
    p = inputParser;

    addParameter(p, 'directory', './power_calculator_results/ground_truth/', @ischar); % Default: 'default'
    addParameter(p, 'gt_origin', 'effect_size');

    %% Get GT data files from directory 
    parse(p, varargin{:});
    gt_dir = p.Results.directory;
    gt_origin = p.Results.gt_origin;

    % Get a list of all .mat files in the directory
    gt_files = {dir(fullfile(gt_dir, '*.mat')).name};
    
    %% Define struct and store data
    GtData = struct;


    %% TODO - improve this 
    switch gt_origin

        case 'effect_size'

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

        case 'power_calculator'  

            for i_f = 1:length(gt_files)

                gt_file_name = gt_files{i_f};
                gt_absolute_file = [gt_dir, gt_file_name];

                data = load(gt_absolute_file);
                
                gt_data = data.brain_data;
                meta_data = data.meta_data;

                base_query_cell = gt_query_cell_generator(meta_data);
                
             
                brain_data_query = [base_query_cell, {'brain_data'}];
                meta_data_query = [base_query_cell, {'meta_data'}];

                GtData = setfield(GtData, brain_data_query{:}, gt_data);
                GtData = setfield(GtData, meta_data_query{:}, meta_data);

                
            end    
    
    end

end
