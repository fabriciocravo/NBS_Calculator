%%%%%
    % Power Calculator
        % IMPORTANT - DISCUSS PARALELISATION PROBLEMS - URGENT
        % Probably didn't run in parallel - I suspect
        % Ask about d, m_test, and m - don't forget to add comment
        % Switch task order - i - there appears to have a leaky i
        % Function - naming practices
        % gt parameters - why?
        % Ask about different atlasses - where are the files 
        % ask about tril mask - network flattening
%%%%%

% Change for test

addpath('/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator')

a = 10;
vars = who;       % Get a list of all variable names in the workspace
vars(strcmp(vars, 'data_matrix')) = [];  % Remove the variable you want to keep from the list
clear(vars{:});   % Clear all other variables
clc;

if ~exist('data_matrix', 'var')
    data_matrix = load('./data/s_hcp_fc_noble_tasks.mat');
else
    %disp('Data already loaded')
end

[current_path,~,~]=fileparts(mfilename('fullpath')); % assuming NBS_benchmarking is current folder
addpath(genpath(current_path));

Params = setparams();
Params = setup_experiment_data(Params, data_matrix);

run_benchmarking(Params);

% I only reviewed the non-ground truth stuff
% RepParams = setup_benchmarking(Params, false);


% Fix gt stuff now
% GtParams = setup_benchmarking(Params, true);



