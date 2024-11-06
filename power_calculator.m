%%%%%
    % Power Calculator
%%%%%

% Change for test

a = 10;
vars = who;       % Get a list of all variable names in the workspace
vars(strcmp(vars, 'data_matrix')) = [];  % Remove the variable you want to keep from the list
clear(vars{:});   % Clear all other variables
clc;

if ~exist('data_matrix', 'var')
    data_matrix = load('./data/s_hcp_fc_noble_tasks.mat');
else
    disp('Data already loaded')
end

[current_path,~,~]=fileparts(mfilename('fullpath')); % assuming NBS_benchmarking is current folder
addpath(genpath(current_path));

Params = setparams();
Params.data = data_matrix;

RepParams = setup_benchmarking(Params, false);

