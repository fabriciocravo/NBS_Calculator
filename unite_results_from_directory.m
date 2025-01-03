% Open data for visualisation script 
function RepetitionResults = unite_results_from_directory(varargin)

    % Create an input parser
    p = inputParser;

    addParameter(p, 'directory', './data_results/with_metadata/', @ischar); % Default: 'default'

    % Parse the inputs
    parse(p, varargin{:});
    data_dir = p.Results.directory;
    
    % Initialise empty struct
    RepetitionResults = struct;

    % Get a list of all .mat files in the directory
    matFiles = dir(fullfile(data_dir, '*.mat'));

    for i = 1:length(matFiles)
        % Get the full file path
        file_path = fullfile(data_dir, matFiles(i).name);
        
        rep_data = load(file_path);
        brain_rep_data = rep_data.data;
        meta_rep_data = rep_data.meta_data;
        
        struct_query = {data_info{1}, data_info{2}, data_info{3}, ...
                        (sprintf('subs_%s', data_info{5}))};
        
        if test_flag
            struct_query = [{'testing'}, myCell];
        end

        %if strcmp(data_info{4}, 'nobus')
        %    struct_query = [myCell];
        %end 

        %% Perform the assigment 
        RepetitionResults = setfield(RepetitionResults, struct_query{:}, load(file_path));    
       
    end
    
end
