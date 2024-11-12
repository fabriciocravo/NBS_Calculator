function Params = setup_experiment_data(Params, data)
    %
    % Description:
    %   This functions take the necessary data from an experiment data set
    %   for the power calculation - for now only the subject data and mask
    %   are needed
    %
    % Input Arguments:
    %   Params - Parameter struct for power calculation
    %   data - experimental data in the correct dataset format
    %
    %
    % Ouput Arguments:
    %   Params - Parameter struct for power calculation with the data from
    %   the experiment added
    %

    Params.brain_data = data.brain_data;
    Params.mask = data.study_info.mask;
end