% Maybe define it locally? Is only used by pfor_repetition_loop
function m_test = pf_single_task_extract_subset(rep_sub_ids, i_rep, Brain_Data, ...
                                                  task_1, mapping_category, triumask, switch_task_order, m_test)

    % if FPR, use the predefined task order
    if ~do_TPR
        if switch_task_order(i_rep, this_repetition)
            task_flipper=-1;
        else
            task_flipper=1;
        end
    else
        task_flipper=1;
    end
    task_flipper=1;
    
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