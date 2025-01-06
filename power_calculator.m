%%%%%
    %% Questions
        % - subtraction and t-test is way more computationally efficient than
        % paired -t
        % - started calculations
        % - in create_test_contrast
            % nbs_exchange for t test? what is it? 
        % - Naming task files - potential issue ?
%%%%%

% Change for test

addpath('/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator')

% Set working directory to the directory of this script
scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);

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

[current_path,~,~]=fileparts(mfilename('fullpath')); % assuming NBS_benchmarking is current folder
addpath(genpath(current_path));

% Infer test types here
% test_type_list = infer_all_test_types(Dataset.outcome, Dataset.brain_data);

Params = setparams();
Params = setup_experiment_data(Params, Dataset);
Params.data_set = get_data_set_name(Dataset);

% setup_parallel_workers(Params.parallel, Params.n_workers);

OutcomeData = Dataset.outcome;
BrainData = Dataset.brain_data;
    
tests = fieldnames(OutcomeData);

for ti = 1:length(tests)
    t = tests{ti};
    % Fix RP both tasks
    % RP - stands for Repetition Parameters
    RP = Params;
    

    RP = infer_test_from_data(RP, OutcomeData.(t), BrainData);
    
    % bellow - gets: test name, subject data, subject numbers, subids, and number of subjects
    [~, Y , RP] = subs_data_from_contrast(RP, OutcomeData.(t).contrast, BrainData);
    
    [RP.triumask, RP.trilmask] = create_masks_from_nodes(size(RP.mask, 1));
    
    % Sets parameters which are different than gt
    %% TODO: THIS DOES NOT MAKE SENSE
    RP = setup_parameters_for_rp(RP);

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



