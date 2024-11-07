%%%%%
    % Power Calculator
    % Planned route - suggest data structure
    % Avoid varargin? - Also I hate this pair value thing from MatLab
    % Template variable - What kind of matrix is it?
    % RepParams.n_node_nets - Number of networks extracted from atlas
    % m - stores something related to ground truth data

    % Template - ask about the following lines:
        %template=importdata(template_file);
        %template_net=summarize_matrix_by_atlas(template(:,:,1),'suppressimg',1);
        %n_node_nets=size(template_net,1); % square
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
Params.data = data_matrix;

% I only reviewed the non-ground truth stuff
RepParams = setup_benchmarking(Params, false);

% Fix gt stuff now
% GtParams = setup_benchmarking(Params, true);



