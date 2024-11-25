function [existence, full_file_path] = create_and_check_rep_file(data_set_name, test_name, stat_type, ...
                                                                omnibus_type, rep_subject_number)
     
    % Initialize the directory where files are stored
    data_dir = './data_results/'; % Adjust this path if needed
    
    rep_file_name = sprintf('%s-%s-%s-%s-%d.m', data_set_name, test_name, stat_type, omnibus_type, ...
                            rep_subject_number);

    % Create the full path to the file
    full_file_path = fullfile(data_dir, rep_file_name);
    
    % Check if the file exists
    existence = isfile(full_file_path);
    
end