function run_benchmarking(RP, Y)
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
    
    %% This line is temporary for testing
    %disp('Temporary assigment still here')
    %RP.all_cluster_stat_types = {'Parametric_Bonferroni', 'Parametric_FDR', 'Size', 'TFCE', ...
    %'Constrained', 'Constrained_FWER', 'Omnibus'};
  
    % RP.list_of_nsubset = {40};

    %% SET Par enviroment
    
    % using parfor which requires Parallel Computing Toolbox, 
    % but if can't get it set to 1 worker in setparams
    % If works are not setup, MatLab runs the parfor
    % sequentially 
    if RP.parallel
        % Setup parallel environment
        c = parcluster('local'); 
        if RP.n_workers > c.NumWorkers
            fprintf('Specified %d workers but only %d available. Setting to max available.\n', ...
                RP.n_workers, c.NumWorkers);
            RP.n_workers = c.NumWorkers;
        end
        
        % Check if a parallel pool exists and delete it
        if ~isempty(gcp('nocreate'))
            fprintf('Deleting existing parallel pool...\n');
            delete(gcp('nocreate'));
        end

        % Create a new parallel pool
        fprintf('Starting parallel pool with %d workers...\n', RP.n_workers);
        parpool(RP.n_workers);
    end


    for stat_id=1:length(RP.all_cluster_stat_types)
        RP.cluster_stat_type = RP.all_cluster_stat_types{stat_id};
        
        tic
        
        [RP.node_nets, RP.trilmask_net, RP.edge_groups] = ...
            extract_atlas_related_parameters(RP, Y);
        
        % If omnibus, we'll loop through all the specified omnibus types
        if ~strcmp(RP.cluster_stat_type, 'Omnibus')
            loop_omnibus_types = {NaN};
        else
            loop_omnibus_types = RP.all_omnibus_types;
        end
        
        for omnibus_id=1:length(loop_omnibus_types) 
            RP.omnibus_type = loop_omnibus_types{omnibus_id};
             
            if ~isnan(RP.omnibus_type)
                RP.omnibus_str = RP.omnibus_type;
            else 
                RP.omnibus_str = 'nobus'; 
            end
            
            for id_nsub_list=1:length(RP.list_of_nsubset)
                RP.n_subs_subset = RP.list_of_nsubset{id_nsub_list};

                %% Create_file_name
                [existence, output_dir] = create_and_check_rep_file(RP.data_set, RP.test_name, ...
                                                                    RP.cluster_stat_type, RP.omnibus_str, ...
                                                                    RP.n_subs_subset, RP.testing);
                if existence && RP.recalculate == 0
                    fprintf('Skipping %s \n', output_dir)
                    continue
                else
                    fprintf('Calculating %s \n', output_dir)
                end

                [UI, RP] = setup_benchmarking(RP, false);
    
                FWER = 0;
                FWER_neg = 0;

                    
                %% PREALOCATE SPACE FOR OUTPUT DATA
                edge_stats_all = zeros(RP.n_var, RP.n_repetitions);
                edge_stats_all_neg = zeros(RP.n_var, RP.n_repetitions);            
               
                disp(length(unique(UI.edge_groups.ui)))

                if contains(UI.statistic_type.ui,'Constrained') || strcmp(UI.statistic_type.ui,'SEA')
                  
                    % minus 1 in all - to not count "zero"
                    cluster_stats_all = zeros(length(unique(UI.edge_groups.ui)) - 1, 1, RP.n_repetitions); 
                    cluster_stats_all_neg = zeros(length(unique(UI.edge_groups.ui)) - 1, 1, RP.n_repetitions); 
                    
                    pvals_all=zeros(length(unique(UI.edge_groups.ui)) - 1, RP.n_repetitions);
                    pvals_all_neg=zeros(length(unique(UI.edge_groups.ui)) - 1, RP.n_repetitions); 
        
                elseif strcmp(UI.statistic_type.ui,'Omnibus')
        
                    if strcmp(UI.omnibus_type.ui,'Multidimensional_cNBS')
                        n_nulls = length(unique(UI.edge_groups.ui))-1;
                    else
                        n_nulls = 1;
                    end
        
                    cluster_stats_all=zeros(1, n_nulls, RP.n_repetitions);
                    cluster_stats_all_neg=zeros(1, n_nulls, RP.n_repetitions);
                    pvals_all=zeros(1, RP.n_repetitions);
                    pvals_all_neg=zeros(1, RP.n_repetitions);
        
                elseif contains(UI.statistic_type.ui,'Parametric')
        
                    cluster_stats_all=zeros(1,1, RP.n_repetitions);
                    cluster_stats_all_neg=zeros(1,1, RP.n_repetitions);
                    pvals_all=zeros(RP.n_nodes*(RP.n_nodes - 1)/2, RP.n_repetitions);
                    pvals_all_neg=zeros(RP.n_nodes*(RP.n_nodes - 1)/2, RP.n_repetitions); 
        
                else
                    
                    cluster_stats_all=zeros(RP.n_nodes, RP.n_nodes, RP.n_repetitions); 
                    cluster_stats_all_neg=zeros(RP.n_nodes, RP.n_nodes, RP.n_repetitions); 
                    pvals_all=zeros(RP.n_nodes*RP.n_nodes, RP.n_repetitions);
                    pvals_all_neg=zeros(RP.n_nodes*RP.n_nodes, RP.n_repetitions);
        
                end
                
                % randomly subsample subject IDs into groups 
                % both t and t2 must have the same sample sizes for this to
                % work properly     
                for r=1:RP.n_repetitions
                    
                    switch RP.test_type
                        
                        case 'pt'

                            ids = randperm(RP.n_subs, RP.n_subs_subset)';
                            ids = [ids; ids + RP.n_subs];

                        case 't2'
                            
                            ids_1 = randperm(RP.n_subs_1, floor(RP.n_subs_subset/2));
                            ids_2 = randperm(RP.n_subs - RP.n_subs_1 + 1, ceil(RP.n_subs_subset/2)) + (RP.n_subs_1 - 1);

                            ids = [ids_1; ids_2];

                        otherwise 

                            ids=randperm(RP.n_subs, RP.n_subs_subset)';

                    end
      
                    ids_sampled(:,r)=ids;

                end                  
               
                % if FPR, set up random task order
                % Note that we don't want to use balanced perms (cf. Southworth et al., Properties of Balanced Permutations)
                if ~RP.do_TPR
                    
                    if (RP.use_both_tasks && RP.paired_design) || ~RP.use_both_tasks
                        switch_task_order = randi([0,1],n_subs_subset, RP.n_repetitions);
                    else
                        error('This script hasn''t been fully updated/tested for two-sample yet.');
                    end
                else
                    % Don't 
                    switch_task_order = [];
                end          
              
                
                if RP.testing
                    fprintf('\n*** TESTING MODE ***\n\n')
                end
                
                % fprintf(['Starting benchmarking - ', RP.task1, '_v_', RP.task2, '::', UI.statistic_type.ui, RP.omnibus_str, '.\n']);
               
                %% Run NBS repetitions
                
                % Be careful with this parfor commented lol
                parfor (i_rep=1: RP.n_repetitions)
                % for i_rep = 1:RP.n_repetitions
                    
                    % Encapsulation of the most computationally intensive loop
                    [FWER_rep, edge_stats_all_rep, pvals_all_rep, cluster_stats_all_rep, ...
                     FWER_neg_rep, edge_stats_all_neg_rep, pvals_all_neg_rep, cluster_stats_all_neg_rep] = ...
                     pf_repetition_loop(i_rep, ids_sampled, switch_task_order, RP, UI, RP.X_rep, Y);
        
                    FWER = FWER + FWER_rep;
                    FWER_neg = FWER_neg + FWER_neg_rep;
        
                    edge_stats_all(:,i_rep) = edge_stats_all_rep;
                    pvals_all(:,i_rep) = pvals_all_rep;
                    edge_stats_all_neg(:,i_rep) = edge_stats_all_neg_rep;
                    pvals_all_neg(:,i_rep) = pvals_all_neg_rep;
                    
                    if ~isempty(cluster_stats_all_rep) || ~isempty(cluster_stats_all_neg_rep)
                        cluster_stats_all(:,:,i_rep) = cluster_stats_all_rep;
                        cluster_stats_all_neg(:,:,i_rep) = cluster_stats_all_neg_rep;
                    end
           
                end
                
                if contains(UI.statistic_type.ui,'Constrained') || strcmp(UI.statistic_type.ui,'SEA') ...
                    || strcmp(UI.statistic_type.ui,'Omnibus')
                    cluster_stats_all = squeeze(cluster_stats_all);
                    cluster_stats_all_neg = squeeze(cluster_stats_all_neg);
                end
                
                run_time = toc;
                
                %% Save

                % Discuss naming with Steph tomorrow 
                if false
                    if strcmp(UI.statistic_type.ui,'Size')
                        size_str = ['_',UI.size.ui];
                    else
                        size_str = '';
                    end
                    
                    if testing
                        test_str = '_testing';
                    else 
                        test_str='';
                    end
                    
                    if do_TPR 
                        TPR_str = '';
                    else 
                        TPR_str = '_shuffled_for_FPR'; 
                    end
                    
                    if use_both_tasks
                        condition_str = [rep_params.task1,'_v_',rep_params.task2];
                    else 
                        condition_str = rep_params.task1;
                    end
                end
            

                %output_filename = [output_dir,'results__',condition_str,TPR_str,'_', ...
                %                   UI.statistic_type.ui,size_str,omnibus_str,'_grsize', ...
                %                   num2str(rep_params.n_subs_subset),test_str,'_', datestr(now,'mmddyyyy_HHMM'),'.mat'];
        
                fprintf('###### Saving results in %s ######### \n', output_dir)
                save(output_dir,'edge_stats_all','cluster_stats_all','pvals_all', ...
                    'FWER','edge_stats_all_neg','cluster_stats_all_neg', ...
                    'pvals_all_neg','FWER_neg','UI','RP', 'run_time');
                
        
            end
        end

    end

end