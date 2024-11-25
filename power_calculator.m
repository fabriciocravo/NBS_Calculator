%%%%%
    % Power Calculator
        % Switch task order - i - there appears to have a leaky i
        % Ask about d, m_test, and m - don't forget to add comment
        % Function - naming practices
        % gt parameters - why?
        % Ask about different atlasses - where are the files 
        % Unflatenning function is not working
        % Do gtr - when? 
%%%%%

% Change for test

addpath('/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator')

a = 10;
vars = who;       % Get a list of all variable names in the workspace
vars(strcmp(vars, 'data_matrix')) = [];  % Remove the variable you want to keep from the list
clear(vars{:});   % Clear all other variables
clc;

data_dir = '/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator/data/s_hcp_fc_noble_tasks.mat';
if ~exist('Dataset', 'var')
    Dataset = load(data_dir);
else
    %disp('Data already loaded')
end
% Extract dataset name
[~, data_set_name, ~] = fileparts(data_dir);

[current_path,~,~]=fileparts(mfilename('fullpath')); % assuming NBS_benchmarking is current folder
addpath(genpath(current_path));

% Infer test types here
% test_type_list = infer_all_test_types(Dataset.outcome, Dataset.brain_data);

Params = setparams();
Params = setup_experiment_data(Params, Dataset);
Params.data_set = data_set_name;

OutcomeData = Dataset.outcome;
BrainData = Dataset.brain_data;
    
tests = fieldnames(OutcomeData);

for ti = 1:length(tests)
    t = tests{ti};
    % Fix RP both tasks
    % RP - stands for Repetition Parameters
    RP = Params;
    RP.test_name = t;


    RP = infer_test_from_data(RP, OutcomeData.(t), BrainData);
    
    % y_and_x also extracts subject number and sub_ids
    [~, Y , RP] = subs_data_from_contrast(RP, OutcomeData.(t).contrast, BrainData);

    run_benchmarking(RP, Y)
    
    % [X, Y] = y_and_x_from_contrast(test_type, Dataset.outcome.test1.contrast, Dataset.outcome, Dataset.brain_data);

    % I will load both X and Y in the run benchmarking I will prepare the
    % parameters as I need them - data is already in X and Y so I sh

    return;

end




% NBS_Output = run_NBS_cl(X, Y, Params);



% run_benchmarking(Params);

% I only reviewed the non-ground truth stuff
% RepParams = setup_benchmarking(Params, false);


% Fix gt stuff now
% GtParams = setup_benchmarking(Params, true);



