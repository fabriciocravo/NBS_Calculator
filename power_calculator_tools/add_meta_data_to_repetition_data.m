function WithMeta = add_meta_data_to_repetition_data(varargin)
    
    WithMeta = struct;

    % Create an input parser
    p = inputParser;
    
    % Default is NaN for all non required
    addRequired(p, 'data'); % The data itself 
    addParameter(p, 'dataset', NaN, @ischar); 
    addParameter(p, 'map', NaN, @ischar); 
    addParameter(p, 'test', NaN, @ischar); 
    addParameter(p, 'test_type', NaN, @ischar);
    addParameter(p, 'omnibus', NaN, @(x) ischar(x) || isnan(x));
    addParameter(p, 'test_components', NaN, @iscell); 
    addParameter(p, 'subject_number', NaN, @isnumeric);
    addParameter(p, 'date', NaN, @ischar);
    addParameter(p, 'testing_code', true, @islogical);

    
    % Parse the inputs
    parse(p, varargin{:});   
    data = p.Results.data;

    dataset = p.Results.dataset;
    map = p.Results.map;
    test = p.Results.test;
    test_type = p.Results.test_type;
    date = p.Results.date;
    test_components = p.Results.test_components; 
    omnibus = p.Results.omnibus;
    subject_number = p.Results.subject_number;
    testing_code = p.Results.testing_code;

    WithMeta.brain_data = data;

    WithMeta.meta_data.dataset = dataset;
    WithMeta.meta_data.map = map;
    WithMeta.meta_data.test = test;
    WithMeta.meta_data.test_type = test_type;
    WithMeta.meta_data.omnibus = omnibus;
    WithMeta.meta_data.test_components = test_components;
    WithMeta.meta_data.subject_number = subject_number;
    WithMeta.meta_data.date = date;
    WithMeta.meta_data.testing_code = testing_code;
    
end

