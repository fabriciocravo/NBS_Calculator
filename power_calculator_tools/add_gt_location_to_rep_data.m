function RepData = add_gt_location_to_rep_data(path_cell, RepData, gt_origin)
    
    %% To finish
    % This function must add the query cell to the Rep_Data 
    %
    % The query contains the location of the ground truth in its respective
    % struct 

    switch gt_origin

        case 'effect_size'

            meta_data = getfield(RepData, path_cell{:});
            query_cell = gt_query_cell_generator(meta_data);
            query_cell = add_gt_info_to_query(query_cell, meta_data);
        
            gt_meta_data_cell_query = [query_cell(1:end-3), {'study_info'}];
            
            % add gt_name to ground truth
            final_path_cell = [path_cell, {'gt_location'}];
            meta_data_path_cell = [path_cell, {'gt_meta_data_location'}];
                
            RepData = setfield(RepData, final_path_cell{:}, query_cell);
            RepData = setfield(RepData, meta_data_path_cell{:}, gt_meta_data_cell_query);
        
        case 'power_calculator'

            meta_data = getfield(RepData, path_cell{:});
            query_cell = gt_query_cell_generator(meta_data);
            
            % Check stat type
            if ismember(meta_data.test_type, {'Constrained', 'Constrained_FWER'})
                stat_level = 'network';
            elseif ismember(meta_data.test_type, {'Parametric_Bonferroni', 'Parametric_FDR', 'Size', 'TFCE'})
                stat_level = 'edge';
            elseif ismember(meta_data.test_type, {'Omnibus'})
                stat_level = 'wholebrain';
            else
                error('Statistical analysis method not supported')
            end
            
            % Location of data and meta-data in gt
            switch stat_level

                case 'edge'
                    data_query_cell = [query_cell, {'brain_data', 'edge_stats_all'}];
                
                case 'network'
                    data_query_cell = [query_cell, {'brain_data', 'cluster_stats_all'}];

                case 'wholebrain'
                    data_query_cell = [query_cell, {'brain_data', 'cluster_stats_all'}];
                    
            end
            meta_query_cell = [query_cell, {'meta_data'}];
            
            % Add location to gt
            final_path_cell = [path_cell, {'gt_location'}];
            meta_data_path_cell = [path_cell, {'gt_meta_data_location'}];

            RepData = setfield(RepData, final_path_cell{:}, data_query_cell);
            RepData = setfield(RepData, meta_data_path_cell{:}, meta_query_cell);

        otherwise 

            error('Origin of ground truth data was not specified')
            
    end

end
