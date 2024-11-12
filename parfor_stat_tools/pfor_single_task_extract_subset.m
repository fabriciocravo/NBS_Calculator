function m_test = pfor_single_task_extract_subset(rep_sub_ids, rep_id, Brain_Data, ...
                                                  task_1, mapping_category, m_test)

    %if FPR, use the predefined task order
    if ~do_TPR
        if switch_task_order(rep_id,this_repetition)
            task_flipper=-1;
        else
            task_flipper=1;
        end
    else
        task_flipper=1;
    end
    
    if use_preaveraged_constrained % no reordering TODO: add above as well
        for i = 1:n_subs_subset
            m_test(:,i) = task_flipper * util_extract_subject_data(Brain_Data, task_1, rep_sub_ids);
        end
    else
        for i = 1:n_subs_subset
            d = util_extract_subject_data(Brain_Data, this_task1, rep_sub_ids);
            d = util_unflatten_diagonal(d);
            d = reorder_matrix_by_atlas(d, mapping_category); % reorder bc proximity matters for SEA and cNBS
            m_test(:,i) = task_flipper * d(triumask);
        end
    end

end