function RepData = add_gt_location_to_rep_data(path_cell, RepData)
    
    %% To finish
    % This function must add the query cell to the Rep_Data 
    %
    % The query contains the location of the ground truth in its respective
    % struct 
    meta_data = getfield(RepData, path_cell{:});
    query_cell = gt_query_cell_generator(meta_data);
    query_cell = add_gt_info_to_query(query_cell, meta_data);

    gt_meta_data_cell_query = [query_cell(1:end-3), {'study_info'}];
    
    % add gt_name to ground truth
    final_path_cell = [path_cell, {'gt_location'}];
    meta_data_path_cell = [path_cell, {'gt_meta_data_location'}];
        
    RepData = setfield(RepData, final_path_cell{:}, query_cell);
    RepData = setfield(RepData, meta_data_path_cell{:}, gt_meta_data_cell_query);


end
