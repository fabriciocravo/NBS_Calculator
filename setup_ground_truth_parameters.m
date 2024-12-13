function RP = setup_ground_truth_parameters(RP)
    
    % This is a ground_truth calculation - set flag to true
    RP.ground_truth = true; 
    
    % gt only has one repetition and the subset of subs is equal to all subs
    RP.n_repetitions = 1; 

    RP.n_subs_subset = RP.n_subs; 
    RP.list_of_nsubset = {RP.n_subs};

    RP.n_subs_subset_c1 = RP.n_subs_1;
    RP.n_subs_subset_c2 = RP.n_subs_2;

    
end
