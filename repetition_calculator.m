
% Set working directory to the directory of this script
scriptDir = fileparts(mfilename('fullpath'));
addpath(genpath(scriptDir));
cd(scriptDir);

vars = who;       % Get a list of all variable names in the workspace
vars(strcmp(vars, 'data_matrix')) = [];  % Remove the variable you want to keep from the list
clear(vars{:});   % Clear all other variables
clc;

%% Prepare parameters and dataset
Params = setparams();

if ~exist('Dataset', 'var')
    Dataset = load(Params.data_dir);
else
    % disp('Data already loaded')
end
Params = setup_experiment_data(Params, Dataset);
Params = create_output_directory(Params);
Params.data_set = get_data_set_name(Dataset);

%% Extract dataset name
[current_path,~,~] = fileparts(mfilename('fullpath')); % assuming NBS_benchmarking is current folder
addpath(genpath(current_path));

setup_parallel_workers(Params.parallel, Params.n_workers);

OutcomeData = Dataset.outcome;
BrainData = Dataset.brain_data;
    
tests = fieldnames(OutcomeData);

for ti = 1:length(tests)
    t = tests{ti};
    % Fix RP both tasks
    % RP - stands for Repetition Parameters
    RP = Params;
    
    %% FOR DEBUGING 
    RP.all_cluster_stat_types = {'Constrained_FWER', 'Constrained'};
    disp('Debugging still here')

    RP = infer_test_from_data(RP, OutcomeData.(t), BrainData);
    
    % bellow - gets: test name, subject data, subject numbers, subids, and number of subjects
    [~, Y , RP] = subs_data_from_contrast(RP, OutcomeData.(t).contrast, BrainData);
    
    [RP.triumask, RP.trilmask] = create_masks_from_nodes(size(RP.mask, 1));
    
    % Sets parameters which are different than gt
    %% TODO: THIS DOES NOT MAKE SENSE
    RP = setup_parameters_for_rp(RP);

    run_benchmarking(RP, Y)

    return;

    %if RP.testing == 1 && ti == 2
    %    return;
    %end
    
end


% NBS_Output = run_NBS_cl(X, Y, Params);



% run_benchmarking(Params);

% I only reviewed the non-ground truth stuff
% RepParams = setup_benchmarking(Params, false);


% Fix gt stuff now
% GtParams = setup_benchmarking(Params, true);



