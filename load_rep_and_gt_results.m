%% QUESTIONS
% Ask steph more about gt data - stats? 
% Why are the pvalues of TFCE and Size doubled? Why whole matrix?
% Constrained_FWER - is it whole brain? It only has one p-value


% Initial setup
addpath('/Users/f.cravogomes/Desktop/Cloned Repos/NBS_Calculator')
scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);
vars = who;       % Get a list of all variable names in the workspace
vars(strcmp(vars, 'Rep_Data')) = [];  % Remove the variable you want to keep from the list
clear(vars{:});   % Clear all other variables
clc;

%% Get rep data
if ~exist('Rep_Data', 'var')
    Rep_Data = unite_results_from_directory();
else
    % disp('Data already loaded')
end

%% Get GT data
GtData = load_gt_data();

%% Load gt data location in rep data
Rep_Data = l_dfs_add_gt_location(Rep_Data, {}, Rep_Data);

function Rep_Data = l_dfs_add_gt_location(node, path_cell, Rep_Data)
     
    fields = fieldnames(node);
    
    %% Loop over 
    for i = 1:numel(fields)
        field_name = fields{i};
        path_cell = [path_cell, {field_name}];

        %% Stopping condition?
        flag_meta = strcmp(field_name, 'meta_data');
        flag_brain = strcmp(field_name, 'brain_data');
        
        if ~flag_meta && ~flag_brain
            l_dfs_add_gt_location(node.(field_name), path_cell, Rep_Data);
        elseif flag_meta
            Rep_Data = add_gt_location_to_rep_data(path_cell, Rep_Data);
        end
        path_cell = path_cell(1:end-1);
    end
end





