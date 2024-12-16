
%% This is a temporary file that adds meta-data to the repetition results file

% Initial setup
addpath('/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator')
scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);

clear;   % Clear all other variables
clc;


data_dir = './data_results/';
save_dir = './data_results/with_metadata/';

matFiles = dir(fullfile(data_dir, '*.mat'));

for i = 1:length(matFiles)
    
    % Get the full file path
    file_path = fullfile(data_dir, matFiles(i).name);
    
    [~, file_name, ~] = fileparts(file_path);

    data_info = strsplit(file_name, '-');

    data = load(file_path);
    
    dummy = strsplit(data_info{1}, '_');
    dataset = dummy{2};
    map = dummy{3};
    test_type = data_info{3};
    components = strsplit(data_info{2}, '_');
    disp(data_info)

    if ~strcmp(data_info{4}, 'nobus')
        omnibus_type = data_info{4};
    else
        omnibus_type = NaN;
    end

    subject_number = str2double(data_info{5});

    % For the current data - all tests were t tests - however, please
    % change if this script is ever needed for something else
    WithMeta = add_meta_data_to_repetition_data(data, 'dataset', dataset, 'map', map, ...
                                                'test', 't', 'test_components', components, ...
                                                'omnibus', omnibus_type, 'subject_number', subject_number, ...
                                                'testing_code', false, 'test_type', test_type);
    
    [~, f_name, f_ext] = fileparts(file_path);
    output_dir = [save_dir, f_name, f_ext];

    brain_data = WithMeta.brain_data;
    meta_data = WithMeta.meta_data;
    save(output_dir, "brain_data", "meta_data");

end







