function run_benchmarking(Params)
% Do NBS-based method benchmarking (cNBS, TFCE, etc)
%
% main outputs:
% edge_stats_all: mean and sd of edge_stats_all
% cluster_stats_all: mean and sd of cluster_stats_all
% pvals_all: total # positives
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup
% make sure config files in NBS_benchmarking are correct

% setparams_bench;

for stat_id=1:length(Params.all_cluster_stat_types)
    
    tic
    cluster_stat_type = Params.all_cluster_stat_types{stat_id};
    
    % If omnibus, we'll loop through all the specified omnibus types
    if ~strcmp(cluster_stat_type,'Omnibus')
        all_omnibus_types={NaN};
    end
    
    for omnibus_id=1:length(all_omnibus_types)

        omnibus_type = all_omnibus_types{omnibus_id};

        if ~isnan(omnibus_type)
            omnibus_str = ['_',omnibus_type];
        else 
            omnibus_str = ''; 
        end
        
        [UI, RepParams] = setup_benchmarking(Params);
        
        disp('All - ok - until here');
        return;

        FWER = 0;
        FWER_neg = 0;

        if use_preaveraged_constrained % not square matrix

            edge_stats_all=zeros(n_var, RepParams.n_repetitions);
            edge_stats_all_neg=zeros(n_var, RepParams.n_repetitions);
        else     

            edge_stats_all=zeros(n_nodes*(n_nodes-1)/2, RepParams.n_repetitions);
            edge_stats_all_neg=zeros(n_nodes*(n_nodes-1)/2, RepParams.n_repetitions);
        end

        if contains(UI.statistic_type.ui,'Constrained') || strcmp(UI.statistic_type.ui,'SEA')

            cluster_stats_all=zeros(length(unique(edge_groups))-1,1, RepParams.n_repetitions); % minus 1 to not count "zero"
            cluster_stats_all_neg=zeros(length(unique(edge_groups))-1,1, RepParams.n_repetitions); % minus 1 to not count "zero"
            pvals_all=zeros(length(unique(UI.edge_groups.ui))-1, RepParams.n_repetitions); % minus 1 to not count "zero"
            pvals_all_neg=zeros(length(unique(UI.edge_groups.ui))-1, RepParams.n_repetitions); % minus 1 to not count "zero"

        elseif strcmp(UI.statistic_type.ui,'Omnibus')

            if strcmp(omnibus_type,'Multidimensional_cNBS')
                n_nulls=length(unique(edge_groups))-1;
            else
                n_nulls=1;
            end

            cluster_stats_all=zeros(1,n_nulls,rep_params.n_repetitions);
            cluster_stats_all_neg=zeros(1,n_nulls,rep_params.n_repetitions);
            pvals_all=zeros(1,rep_params.n_repetitions);
            pvals_all_neg=zeros(1,rep_params.n_repetitions);

        elseif contains(UI.statistic_type.ui,'Parametric')

            cluster_stats_all=zeros(1,1,rep_params.n_repetitions);
            cluster_stats_all_neg=zeros(1,1,rep_params.n_repetitions);
            pvals_all=zeros(n_nodes*(n_nodes-1)/2,rep_params.n_repetitions);
            pvals_all_neg=zeros(n_nodes*(n_nodes-1)/2,rep_params.n_repetitions); 

        else
            
            cluster_stats_all=zeros(n_nodes,n_nodes,rep_params.n_repetitions); 
            cluster_stats_all_neg=zeros(n_nodes,n_nodes,rep_params.n_repetitions); 
            pvals_all=zeros(n_nodes*n_nodes,rep_params.n_repetitions);
            pvals_all_neg=zeros(n_nodes*n_nodes,rep_params.n_repetitions);

        end
        %end
        
        % randomly subsample subject IDs into groups 
        for r=1:rep_params.n_repetitions

            if use_both_tasks

                if paired_design
                    ids=randperm(n_subs,n_subs_subset)';
                    ids=[ids;ids+n_subs];
                else
                    error('This script hasn''t been fully updated/tested for two-sample yet.');
                    ids=randperm(n_subs,n_subs_subset*2)';
                end

            else

                ids=randperm(n_subs,n_subs_subset)';
            end

            ids_sampled(:,r)=ids;
        end
        
        % if FPR, set up random task order
        % Note that we don't want to use balanced perms (cf. Southworth et al., Properties of Balanced Permutations)
        if ~do_TPR
            
            if (use_both_tasks && paired_design) || ~use_both_tasks
                switch_task_order=randi([0,1],n_subs_subset,rep_params.n_repetitions);
            else
                error('This script hasn''t been fully updated/tested for two-sample yet.');
            end
        end
        
        
        %% Run NBS repetitions
        % using parfor which requires Parallel Computing Toolbox, but if can't get it set to 1 worker in setparams
        
        c = parcluster('local');
        if n_workers>c.NumWorkers
            fprintf('Specified %d workers but only %d available. Setting to max available.\n',n_workers,c.NumWorkers);
             n_workers=c.NumWorkers;
        end

        if isempty(gcp('nocreate'))
            my_pool = parpool(n_workers);
        end % set from here bc doesn't limit to the specified n streams on server
        
        if rep_params.testing
            fprintf('\n*** TESTING MODE ***\n\n')
        end

        fprintf(['Starting benchmarking - ',task1,'_v_',task2,'::',UI.statistic_type.ui,omnibus_str,'.\n']);
        
        
        parfor (this_repetition=1:rep_params.n_repetitions)
            
            % Encapsulation of the most computationally intensive loop
            pfor_repetition_loop()
    
        end
        
        if contains(UI.statistic_type.ui,'Constrained') || strcmp(UI.statistic_type.ui,'SEA') || strcmp(UI.statistic_type.ui,'Omnibus')
           cluster_stats_all=squeeze(cluster_stats_all);
           cluster_stats_all_neg=squeeze(cluster_stats_all_neg);
        end
        
        run_time=toc;
        
        
        %% Save
        
        mkdir(output_dir)
        
        if strcmp(UI.statistic_type.ui,'Size'); size_str=['_',UI.size.ui];
        else; size_str='';
        end
        
        if testing; test_str='_testing'; else test_str=''; end
        if do_TPR; TPR_str=''; else TPR_str='_shuffled_for_FPR'; end
        
        if use_both_tasks; condition_str=[rep_params.task1,'_v_',rep_params.task2];
        else; condition_str=rep_params.task1;
        end
        
        output_filename=[output_dir,'results__',condition_str,TPR_str,'_',UI.statistic_type.ui,size_str,omnibus_str,'_grsize',num2str(rep_params.n_subs_subset),test_str,'_',datestr(now,'mmddyyyy_HHMM'),'.mat'];
        fprintf('Saving results in %s\n',output_filename)
        save(output_filename,'edge_stats_all','cluster_stats_all','pvals_all','FWER','edge_stats_all_neg','cluster_stats_all_neg','pvals_all_neg','FWER_neg','UI','rep_params','run_time');
        
        % show that results are available in the workspace
        previous_results_filename__already_loaded=output_filename;
        
    end
end

end