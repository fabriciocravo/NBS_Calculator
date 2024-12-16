function Rep_Data = add_gt_location_to_rep_data(path_cell, Rep_Data)
    
    %% To finish
    % This function must add the query cell to the Rep_Data 
    %
    % The query contains the location of the ground truth in its respective
    % struct 
    meta_data = getfield(Rep_Data, path_cell{:});
    
    query_cell = gt_query_cell_generator(meta_data);
    query_cell = add_gt_info_to_query(query_cell, meta_data);
    disp(query_cell)
    
end
