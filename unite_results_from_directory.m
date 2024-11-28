% Open data for visualisation script 
function RepetitionResults = unite_results_from_directory(varargin)
    % Create an input parser
    p = inputParser;

    addParameter(p, 'directory', './data_results/', @ischar); % Default: 'default'

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
        
        [~, file_name, ~] = fileparts(file_path);

        data_info = strsplit(file_name, '-');
        disp(data_info)
        strcmp(data_info{6}, 'test')
        
        % Separate between testing and non-testing cases
        if strcmp(data_info{4}, 'nobus') && ~strcmp(data_info{6}, 'test')

            RepetitionResults.(data_info{1}).(data_info{2}).(data_info{3}). ...
            (sprintf('subs_%s', data_info{5})) = load(file_path);

        elseif ~strcmp(data_info{4}, 'nobus') && ~strcmp(data_info{6}, 'test')

            RepetitionResults.(data_info{1}).(data_info{2}).(data_info{3}).(data_info{4}). ...
            (sprintf('subs_%s', data_info{5})) = load(file_path);

        elseif strcmp(data_info{4}, 'nobus') && strcmp(data_info{6}, 'test')

            RepetitionResults.testing.(data_info{1}).(data_info{2}).(data_info{3}). ...
            (sprintf('subs_%s', data_info{5})) = load(file_path);
        
        elseif ~strcmp(data_info{4}, 'nobus') && strcmp(data_info{6}, 'test')

            RepetitionResults.testing.(data_info{1}).(data_info{2}).(data_info{3}). ...
            (sprintf('subs_%s', data_info{5})) = load(file_path);
        
        else
            continue

        end    
       
    end
    
end
