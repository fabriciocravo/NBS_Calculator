function [UI, RepParams] = setup_benchmarking(Params, do_gt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Setup for running NBS benchmarking
% This will load data and set up the parameters needed to run NBS benchmarking
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

RepParams = Params;

addpath(genpath(RepParams.nbs_dir));
addpath(genpath(RepParams.other_scripts_dir));

% Developers: parameter changes
if RepParams.testing
    RepParams.n_perms = RepParams.test_n_perms;
    RepParams.n_repetitions = RepParams.test_n_repetitions;
    RepParams.n_workers = RepParams.test_n_workers;
end

% set ground truth parameters
if do_gt
    RepParams.do_ground_truth = 1;
    RepParams.task1 = RepParams.task_gt;
    RepParams.do_TPR = 1;
    %use_both_tasks=1;
    RepParams.cluster_stat_type = RepParams.stat_type_gt;
    %cluster_stat_type='Size';
    RepParams.omnibus_type = RepParams.omnibus_type_gt;
    RepParams.n_perms = RepParams.n_perms_gt;
    %n_perms='1';
  
    if ~RepParams.use_both_tasks % temporary check that both tasks are being used
        warning(['Not performing a contrast between two tasks. ' ...
            'Specify ''use_both_tasks=1'' to match results from Levels of Inference study.'])
    end
else
    RepParams.do_ground_truth = 0;
end

% special setup for nonparametric FDR (part of classic NBS toolbox) and parametric FDR and Bonferroni (newly added here)  since can't run it using cluster_stat_type
if strcmp(RepParams.cluster_stat_type,'FDR')
    RepParams.nbs_method='Run FDR';
elseif strcmp(RepParams.cluster_stat_type,'Parametric_FDR') ...
       || strcmp(RepParams.cluster_stat_type,'Parametric_Bonferroni')
    RepParams.nbs_method='Run Parametric Edge-Level Correction';
end

%% Check expected inclusion of resting tasks
if RepParams.use_both_tasks
    if RepParams.do_TPR
        if ~contains(RepParams.task2,'REST') 
        %if ~(strcmp(task2,'REST') || strcmp(task2,'REST2'))
            warning(['Not using REST or REST2 for contrasting with task; ' ...
                'this differs from the intended use of these benchmarking scripts.']);
        else
            if RepParams.use_trimmed_rest
                disp('Fix this too')
                RepParams.task2=[RepParams.task2,'_',num2str(RepParams.n_frames.(task1)),'frames'];
                if RepParams.do_TPR
                    warning('Using trimmed rest for power calculation.');
                end
            end
        end
    else
        if ~(contains(RepParams.task1,'REST') && contains(RepParams.task2,'REST'))
        %if ~((strcmp(task1,'REST') && strcmp(task2,'REST2')) || (strcmp(task1,'REST2') && strcmp(task2,'REST')))
            error('Not using REST vs. REST2 or REST2 vs. REST for estimating false positives; this differs from the intended use of these benchmarking scripts.');
        else
            if RepParams.use_trimmed_rest
                RepParams.task1=[RepParams.task1,'_',num2str(RepParams.n_frames.(task1)),'frames'];
                RepParams.task2=[RepParams.task2,'_',num2str(RepParams.n_frames.(task2)),'frames'];
            end
        end
    end
end
    
%% Get subjects IDs, num subjects, num nodes

% get subject task1 IDs and matrix data
RepParams.task1_IDs = RepParams.brain_data.(RepParams.task1).sub_ids;

% if do_TPR
if RepParams.use_both_tasks % doing a paired sample test

    % compare IDs (thanks https://www.mathworks.com/matlabcentral/answers/358722-how-to-compare-words-from-two-text-files-and-get-output-as-number-of-matching-words)

    % get task2 IDs
    RepParams.task2_IDs = RepParams.brain_data.(RepParams.task2).sub_ids;
    
    % compare task1 w task2
    %fprintf(['Comparing subject IDs from from task1:\n(',RepParams.task1,')\n' ...
    %        'with IDs from task2:\n(',RepParams.task2,').\n']);
    RepParams.subIDs = intersect(RepParams.task1_IDs, RepParams.task2_IDs);
    %subIDs=subIDs(2:end); % in case the first find is empty - TODO add a check here first - NEW should be fine now bc checking for empty in task1_IDs and task2_IDs AND explicitly checking for empty in intersection

else % doing a one-sample test
    %fprintf(['Using subject IDs from from task1 (',RepParams.task2,').\n']);
    RepParams.subIDs = RepParams.task1_IDs;
end

% Developers: if testing limit to subset of data
if RepParams.testing
    RepParams.n_subs = RepParams.n_subs_subset;
else
    RepParams.n_subs = length(RepParams.subIDs);
end

% if doing ground truth, use all data
if RepParams.do_ground_truth
    RepParams.n_subs_subset = RepParams.n_subs;
end

% This line extracts the number of nodes (voxels, areas) 
% Do n_var*(n_var - 1)/2 for number of fc links
RepParams.n_var = sum(RepParams.mask(:));

if ~RepParams.use_preaveraged_constrained
    RepParams.n_nodes = size(RepParams.mask, 1); 
    
    template_net = summarize_matrix_by_atlas(RepParams.brain_data.(RepParams.task1).data(:, 1), ...
                                             'suppressimg', 1, 'mask', RepParams.mask);
    
    RepParams.n_node_nets = size(template_net, 1); % square
    RepParams.trilmask_net = tril(true(RepParams.n_node_nets)); 

    % I know it's annoying to switch to tril here instead of triu, but summarize_matrix_by_atlas gives results in lower triangle (tril is my habit) while NBS uses triu...
end

%% GROUND TRUTH ONLY: Pre-load and reorder data unless already specified to be loaded
% note that for benchmarking (not ground truth), we load/reorder data during each repetition

if RepParams.do_ground_truth
    
    load_data='y';
    if exist('m','var')
        load_data=input('Some data is already loaded in the workspace. Replace? (y/n)','s');
    end

    if strcmp(load_data,'y')
    
        %fprintf('Loading %d subjects. Progress:\n', RepParams.n_subs);

        % load data differently for paired or one-sample test
        if RepParams.use_both_tasks % for paired
            
            if RepParams.paired_design
                if RepParams.use_preaveraged_constrained % no need to reorder/pool

                    m = zeros(RepParams.n_var, RepParams.n_subs*2);

                    for i = 1:RepParams.n_subs                   

                        m(:, i) = util_extract_subject_data(RepParams.brain_data, task1, i);                
                                            
                        m(:,n_subs + i) = util_extract_subject_data(RepParams.brain_data, task2, i);
                        
                        % print every 50 subs x 2 tasks
                        %if mod(i,50)==0 
                        %    fprintf('%d/%d  (x2 tasks)\n',i,n_subs)
                        %end
                    end
                else % go ahead and reorder by atlas and pool by nets/all for ground truth

                    m = zeros(RepParams.n_nodes*(RepParams.n_nodes-1)/2, RepParams.n_subs*2);
                    m_net = zeros(RepParams.n_node_nets*(RepParams.n_node_nets-1)/2+RepParams.n_node_nets, ...
                                  RepParams.n_subs * 2);
                    m_pool_all = zeros(1, RepParams.n_subs * 2);

                    for i = 1:RepParams.n_subs
                
                        sub_data_t1 = util_extract_subject_data(RepParams.brain_data, task1, i);
                        m(:,i) = sub_data_t1;
                        
                        d = util_unflatten_diagonal(sub_data_t1);      

                        d_net = summarize_matrix_by_atlas(d, 'suppressimg', 1);
                        m_net(:,i) = d_net(RepParams.trilmask_net);  
                      
                        m_pool_all(i) = mean(d(RepParams.triumask));
                        
                        sub_data_t2 = util_extract_subject_data(RepParams.brain_data, task2, i);
                        m(:,RepParams.n_subs + i) = sub_data_t2;

                        d = util_unflatten_diagonal(sub_data_t2);  
                        
                        d_net = summarize_matrix_by_atlas(d,'suppressimg',1);
                        m_net(:,RepParams.n_subs + i) = d_net(RepParams.trilmask_net);
                        
                        m_pool_all(RepParams.n_subs + i) = mean(d(RepParams.triumask)); 

                        % print every 50 subs x 2 tasks
                        %if mod(i,50)==0 
                        %    fprintf('%d/%d  (x2 tasks)\n', i, RepParams.n_subs) 
                        %end
                    end
                end
            else
                error('This script hasn''t been fully updated/tested for two-sample yet.');
            end
        
        else % for single task v 0

            if use_preaveraged_constrained % no need to reorder/pool
                m = zeros(RepParams.n_var, RepParams.n_subs);

                for i = 1:n_subs
                    
                    m(:,i) = util_extract_subject_data(RepParams.brain_data, task1, i);
                    
                end
            else % go ahead and reorder by atlas and pool by nets/all for ground truth
                m = zeros(RepParams.n_nodes*(RepParams.n_nodes-1)/2, RepParams.n_subs);
                m_net = zeros(RepParams.n_node_nets*(RepParams.n_node_nets-1)/2 + RepParams.n_node_nets, ...
                              RepParams.n_subs);
                m_pool_all=zeros(1, RepParams.n_subs);

                for i = 1:n_subs  
                    
                    sub_data_t1 = util_extract_subject_data(RepParams.brain_data, task1, i);                            
                    
                    d = util_unflatten_diagonal(sub_data_t1);    
                    
                    % reorder bc proximity matters for SEA and cNBS
                    d=reorder_matrix_by_atlas(d, mapping_category); 
                    m(:, i) = d(triumask);

                    d_net=summarize_matrix_by_atlas(d,'suppressimg',1);

                    m_net(:, i) = d_net(trilmask_net);
                    m_pool_all(i) = mean(d(triumask));
                    % print every 100
                    % if mod(i,100)==0; fprintf('%d/%d\n',i,n_subs); end
                end
            end 
        end

    else
        fprintf('Okay, keeping previous data and assuming already reordered.\n');
    end

end

%% Set up design matrix, contrasts, and (for cNBS) edge groups

if RepParams.use_both_tasks
    
    if RepParams.paired_design
        
        % set up design matrix for paired one-sample t-test
        % data should be organized: s1_gr1,s2_gr1, ... , sn-1_group2, sn_group2
        dmat = zeros(RepParams.n_subs_subset * 2, RepParams.n_subs_subset + 1);
        dmat(1:(RepParams.n_subs_subset), 1) = 1;
        dmat((RepParams.n_subs_subset + 1):end, 1) = -1;

        for i=1:RepParams.n_subs_subset
            dmat(i,i+1)=1;
            dmat(RepParams.n_subs_subset + i, i + 1) = 1;
        end

        % set up contrasts - positive and negative
        nbs_contrast = zeros(1, RepParams.n_subs_subset + 1);
        nbs_contrast(1)=1;

        nbs_contrast_neg=nbs_contrast;
        nbs_contrast_neg(1)=-1;

        % set up exchange
        nbs_exchange=[1: RepParams.n_subs_subset, 1:RepParams.n_subs_subset];
        
    else % two-sample test
            
            error('This script hasn''t been fully updated/tested for two-sample yet.');
            % set up design matrix for two-sample t-test
            % data should be organized: s1_gr1, ... sn_gr1, sn+1_gr2, ... s2*n_gr2
            dmat = zeros(n_subs_subset,2);
            dmat(1:(n_subs_subset/2),1)=1;
            dmat((n_subs_subset/2+1):end,2)=1;

            % set up contrasts - positive and negative
            nbs_contrast=[1,-1];
            nbs_contrast_neg=[-1,1];

            % set up exchange
            nbs_exchange='';
    end

else
    
    % set up design matrix for one-sample t-test
    % data should be organized: s1, ..., sn
    dmat = ones(RepParams.n_subs_subset, 1);

    % set up contrasts - positive and negative
    nbs_contrast=[1];
    nbs_contrast_neg=[-1];

    % set up exchange
    nbs_exchange='';
end

% make edge groupings (for cNBS/SEA)
if ~RepParams.use_preaveraged_constrained % no need to reorder/pool
    edge_groups = load_atlas_edge_groups(RepParams.n_nodes, RepParams.mapping_category);
    edge_groups = tril(edge_groups,-1);
    % TODO: in NBS function, should we require zero diag? Automatically clear diag? Something else?
else
    edge_groups=1:length(RepParams.triumask)+1; % plus 1 because the script expects there to be a "0" (and will subsequently ignore..."
end

%% Assign params to structures
% Goal: should be able to run config file, load rep_params and UI from reference, and replicate reference results

% assign repetition parameters to rep_params
% Not needed anymore after modularization
%rep_params.data_dir=data_dir;
%rep_params.testing=testing;
%rep_params.do_simulated_effect=do_simulated_effect;
%rep_params.networks_with_effects=networks_with_effects;
%rep_params.mapping_category=mapping_category;
%rep_params.n_repetitions=n_repetitions;
%rep_params.n_subs_subset=n_subs_subset;
%rep_params.do_TPR=do_TPR;
%rep_params.use_both_tasks=use_both_tasks;
%rep_params.paired_design=paired_design;
%rep_params.task1=task1;
%if use_both_tasks; rep_params.task2=task2; end

% assign NBS parameters to UI (see NBS.m)
UI.method.ui = RepParams.nbs_method;
UI.design.ui = dmat;
UI.contrast.ui = nbs_contrast;
UI.test.ui = RepParams.nbs_test_stat; % alternatives are one-sample and F-test
UI.perms.ui = RepParams.n_perms;
UI.thresh.ui = RepParams.tthresh_first_level;
UI.alpha.ui = RepParams.pthresh_second_level;
UI.statistic_type.ui = RepParams.cluster_stat_type; 
UI.size.ui = RepParams.cluster_size_type;
UI.omnibus_type.ui = RepParams.omnibus_type; 
UI.edge_groups.ui = edge_groups;
UI.use_preaveraged_constrained.ui = edge_groups;
UI.exchange.ui = nbs_exchange;
% UI.do_Constrained_FWER_second_level.ui=do_Constrained_FWER_second_level;

% Non - NBS data - data not needed for the NBS execution
% Store negative and positive contrast in UI - might result in bugs -
% hopefullly not
UI.nbs_contrast_neg = nbs_contrast_neg;
% store original contrast as well - avoid losing it when it's set to negative
UI.nbs_contrast = nbs_contrast; 

end

