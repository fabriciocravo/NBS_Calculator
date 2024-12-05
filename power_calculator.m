%%%%%
    %% Questions
        % - subtraction and t-test is way more computationally efficient than
        % paired -t
        % - started calculations
        % - in create_test_contrast
            % nbs_exchange for t test? what is it? 
%%%%%

% Change for test

addpath('/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator')

% Set working directory to the directory of this script
scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);

a = 10;
vars = who;       % Get a list of all variable names in the workspace
vars(strcmp(vars, 'data_matrix')) = [];  % Remove the variable you want to keep from the list
clear(vars{:});   % Clear all other variables
clc;

data_dir = '/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator/data/s_hcp_fc_noble_tasks.mat';
if ~exist('Dataset', 'var')
    Dataset = load(data_dir);
else
    % disp('Data already loaded')
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
    % Encapsulate this level of setup in a function if there is to much
    % function calls here 
    [X, Y , RP] = subs_data_from_contrast(RP, OutcomeData.(t).contrast, BrainData);
    [RP.triumask, RP.trilmask] = create_masks_from_nodes(size(RP.mask, 1));

    run_benchmarking(RP, Y)

    if RP.testing == 1 && ti == 2
        return;
    end
    
end




% NBS_Output = run_NBS_cl(X, Y, Params);



% run_benchmarking(Params);

% I only reviewed the non-ground truth stuff
% RepParams = setup_benchmarking(Params, false);


% Fix gt stuff now
% GtParams = setup_benchmarking(Params, true);



