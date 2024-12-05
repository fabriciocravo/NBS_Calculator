function [nbs_contrast, nbs_contrast_neg, nbs_exchange] = create_test_contrast(test_type, n_subs)
    
    nbs_contrast = [];
    nbs_contrast_neg = [];

    switch test_type

        case 't'

            nbs_contrast = 1;
            nbs_contrast_neg = -1;
            nbs_exchange='';
       
        case 't2'

            nbs_contrast=[1,-1];
            nbs_contrast_neg=[-1,1];  
            nbs_exchange='';

        case 'pt'  
            % set up contrasts - positive and negative
            nbs_contrast = zeros(1, n_subs + 1);
            nbs_contrast(1)=1;
    
            nbs_contrast_neg=nbs_contrast;
            nbs_contrast_neg(1)=-1;

            nbs_exchange=[1:n_subs, 1:n_subs];
        
    end

end   

