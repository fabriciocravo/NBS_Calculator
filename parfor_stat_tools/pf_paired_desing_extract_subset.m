% Maybe define it locally? Is only used by pfor_repetition_loop
function m_test = pf_paired_desing_extract_subset(rep_sub_ids, i_rep, Brain_Data, task1, task2, ...
                                                  mapping_category, triumask, do_TPR, switch_task_order, ...
                                                  n_subs_subset, m_test)
    %
    % Description:
    %   This funtion extracts the necessary experiment data for a small
    %   repetition using only part of the dataset. It can also rearange
    %   tasks for null estimation in permutation testing
    %
    % Input Arguments:
    %   experiment_data - Data from data.brain_data in the dataset format
    %   task1 - First task being tested in the paired design
    %   task2 - Second task
    %   mapping_category - network statistics mapping categorary for atlas
    %   do_TPR - do true positive rate 
    %   n_subs_subset - number of subjects for this subset repetition
    %   m_test - prealocated m space with all zero
    %
    % Ouput Arguments:
    %   d - data
    %   m_test - output data
    %
    
    for i = 1:n_subs_subset
                        
        %if FPR, use the predefined task order
        if ~do_TPR
            if switch_task_order(i, this_repetition)
                this_task1=task1; 
                this_task2=task2;
            else
                this_task1=task2; 
                this_task2=task1;
            end
        else
            this_task1=task1;
            this_task2=task2;
        end
        
        d = util_extract_subject_data(Brain_Data, this_task1, rep_sub_ids);
        d = util_unflatten_diagonal(d);
        d = reorder_matrix_by_atlas(d, mapping_category); % reorder bc proximity matters for SEA and cNBS
        m_test(:,i) = d(triumask);
        
        d = util_extract_subject_data(Brain_Data, this_task2, rep_sub_ids);
        d = util_unflatten_diagonal(d);
        d = reorder_matrix_by_atlas(d,mapping_category); % reorder bc proximity matters for SEA and cNBS
        m_test(:,n_subs_subset + i) = d(triumask);
        
    end
end