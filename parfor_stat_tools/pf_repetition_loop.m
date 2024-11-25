function [FWER_rep, edge_stats_rep, pvals_rep, cluster_stats_rep, ...
          FWER_rep_neg, edge_stats_rep_neg, pvals_rep_neg, cluster_stats_rep_neg] = ...
          pf_repetition_loop(i_rep, ids_sampled, switch_task_order, RepParams, UI, X_rep, Y)

    %
    % Description:
    %   This encapsulates the most computationally intensive parts of the
    %   script. By putting into a function, it becomes easier for matlab to
    %   paralellise and isolate an local enviroment for each iteraction. 
    %   WARNING - DO NOT VARGIN THIS - IF THERE IS A VARIABLE ISSUE HANDLE
    %   OUTSIDE THE PARFOR (reason - better speed and performance)
    % 
    % Input Arguments:
    %   i_rep - index of respective repetition
    %   ids_sampled - random subset of subject ids to be used for this
    %   repetion
    %   switch_task_order - list with task order for each rep
    %   RepParams - repetition parameters
    %   UI - struct that configures nbs
    % 
    % Ouput Arguments:
    %   The results of this repetition statistical tests 
    %
    % fprintf('* Repetition %d - positive contrast\n', i_rep) 

    rep_sub_ids = ids_sampled(:, i_rep);
    
    % Extract data points for this repetion 
    Y_rep = Y(:, rep_sub_ids);
     
    if RepParams.use_both_tasks 
         
        Y_rep = pf_paired_atlas_order(Y_rep, ...
                                      RepParams.mapping_category, ...
                                      RepParams.mask, RepParams.do_TPR, switch_task_order, ...
                                      RepParams.n_subs_subset); 
            
    else

        Y_rep = pf_sinle_atlas_order(Y_rep, i_rep, ...
                                     RepParams.mapping_category, RepParams.mask, ...
                                     switch_task_order);

    end

    % Assign setup_benchmark parameters to new UI
    UI_new = UI;
    
    % Set this repetition design matrix and Y_rep 
    UI_new.design.ui = X_rep;
    UI_new.matrices.ui = Y_rep;
    UI_new.contrast.ui = RepParams.nbs_contrast;  
    
    nbs = NBSrun_smn(UI_new);
    
    % re-run with negative
    % fprintf('* Repetition %d - negative contrast\n', i_rep)
    
    % Change constrast to negative one 
    UI_new_neg = UI_new;
    UI_new_neg.contrast.ui = RepParams.nbs_contrast_neg;

    nbs_neg = NBSrun_smn(UI_new_neg);
    

    % check for any positives (if there was no ground truth effect, this goes into the FWER calculation)
    if nbs.NBS.n > 0
        FWER_rep = 1;
    end

    if nbs_neg.NBS.n > 0
        FWER_rep_neg = 1;
    end

    % record everything
    if strcmp(RepParams.cluster_stat_type,'FDR') || contains(RepParams.cluster_stat_type,'Parametric')

	    % Note: NBS's FDR does not return corrected p-values, only significant edges 
        % (con_mat)--assigning significant edges to a pvalue of "0" and 
        % non-significant to pvalue "1" JUST for summarization purposes
        edge_stats_rep = nbs.NBS.test_stat(triumask);
        pvals_rep = ~nbs.NBS.con_mat{1}(:); % see above note 
        
        edge_stats_rep_neg = nbs_neg.NBS.test_stat(triumask);
        pvals_rep_neg = ~nbs_neg.NBS.con_mat{1}(:);  % see above note
        
        % This is not generated for this stats test, so I just output an
        % empty list
        cluster_stats_rep = [];
        cluster_stats_rep_neg = [];

    else
        
         % TODO: had to vectorize for TFCE... should give all outputs in same format tho
        edge_stats_rep = nbs.NBS.edge_stats;
        pvals_rep = nbs.NBS.pval(:); 

        edge_stats_rep_neg = nbs_neg.NBS.edge_stats;
        pvals_rep_neg = nbs_neg.NBS.pval(:); % TODO: same as above
        
        % Todo - add - remove - idk why this is here
        % if strcmp(UI.statistic_type.ui,'Omnibus') % single result for omnibus
        %  cluster_stats_all(this_repetition)=full(nbs.NBS.cluster_stats);
        % cluster_stats_all_neg(this_repetition)=full(nbs_neg.NBS.cluster_stats);
        
        %  else

        cluster_stats_rep = full(nbs.NBS.cluster_stats);
        cluster_stats_rep_neg = full(nbs_neg.NBS.cluster_stats);
 
    end
    
end