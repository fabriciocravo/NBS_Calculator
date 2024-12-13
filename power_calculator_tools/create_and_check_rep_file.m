function [existence, full_file_path] = create_and_check_rep_file(data_set_name, test_name, stat_type, ...
                                                                omnibus_type, rep_subject_number, testing, ...
                                                                ground_truth)
     
    % Initialize the directory where files are stored
    %% TODO - REMOVE THIS FROM HERE - PUT IT IN PROPER SCRIPT
    data_dir = './data_results/'; % Adjust this path if needed
    
    if testing == 0
        rep_file_name = sprintf('%s-%s-%s-%s-%d.mat', data_set_name, test_name, stat_type, omnibus_type, ...
                                rep_subject_number);
    else
        rep_file_name = sprintf('%s-%s-%s-%s-%d-test.mat', data_set_name, test_name, stat_type, omnibus_type, ...
                                rep_subject_number);
    end

    if ground_truth
        rep_file_name = strcat('gt_', rep_file_name);
    end

    % Create the full path to the file
    full_file_path = fullfile(data_dir, rep_file_name);
    
    % Check if the file exists
    existence = isfile(full_file_path);
    
end