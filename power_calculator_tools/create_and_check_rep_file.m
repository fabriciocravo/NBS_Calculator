function [existence, full_file_path] = create_and_check_rep_file(data_dir, data_set_name, test_components, ...
                                                                 test_type, stat_type, ...
                                                                 omnibus_type, rep_subject_number, testing, ...
                                                                 ground_truth)
    
    %% Preprocess inputs
    subject_number_str = strcat('subs_', int2str(rep_subject_number));
   
    % Process nobus if there is none
    if isnan(omnibus_type)
        omnibus_type = 'nobus';
    end

    %% Make file name
    if testing == 0
        rep_file_name = sprintf('%s-%s-%s-%s-%s-%s.mat', data_set_name, test_components, test_type, ...
                                stat_type, omnibus_type, subject_number_str);
    else
        rep_file_name = sprintf('%s-%s-%s-%s-%s-%s-test.mat', data_set_name, test_components, test_type, ...
                                stat_type, omnibus_type, subject_number_str);
    end

    if ground_truth
        rep_file_name = strcat('gt_', rep_file_name);
    end

    % Create the full path to the file
    full_file_path = fullfile(data_dir, rep_file_name);
    
    % Check if the file exists
    existence = isfile(full_file_path);
    
end