%%%%%
    % Power Calculator
%%%%%

clear;
clc;

[current_path,~,~]=fileparts(mfilename('fullpath')); % assuming NBS_benchmarking is current folder
addpath(genpath(current_path));

Params = setparams();
RepParams = setup_benchmarking(Params, false);

