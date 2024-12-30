%% Questions
    % in summarize_tools - calculate_tpr - is there an issue when dividing
    % by the repetitions? shouldn't we only consider repetitions where it's
    % positive 

% Initial setup
addpath(genpath('/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator'))
scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);
vars = who;       % Get a list of all variable names in the workspace
vars(strcmp(vars, 'RepData')) = [];  % Remove the variable you want to keep from the list
vars(strcmp(vars, 'GtData')) = [];
clear(vars{:});   % Clear all other variables
clc;

%% Directory to save and find rep data - TODO add them all
power_dir_save_location = './data_results/power_calculation/';


%% Create storage directory - only if it does not exist
if ~exist(power_dir_save_location, 'dir') % Check if the directory does not exist
    mkdir(power_dir_save_location);       % Create the directory
end

if ~exist('RepData', 'var') || ~exist('GtData', 'var')
    [GtData, RepData] = load_rep_and_gt_results();
end 

power_calculation_tprs = @(x) summarize_tprs('calculate_tpr', x, GtData, ...
                                             'save_directory', power_dir_save_location);
dfs_struct(power_calculation_tprs, RepData);

