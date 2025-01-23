function unflat_matrix = unflatten_matrix(flat_matrix, mask)

    % - reorder_matrix_by_atlas only applies to shen atlas
        % - full information before reordering
    temp_y = zeros(size(mask));
    temp_y(mask) = flat_matrix;
    % make full matrix, not upper or lower tri, before reordering
    unflat_matrix = temp_y + temp_y';

end