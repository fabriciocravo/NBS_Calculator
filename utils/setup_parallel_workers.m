function setup_parallel_workers(flag, worker_number)
% using parfor which requires Parallel Computing Toolbox, 
    % but if can't get it set to 1 worker in setparams
    % If works are not setup, MatLab runs the parfor
    % sequentially 
    if flag
        % Setup parallel environment
        c = parcluster('local'); 
        if worker_number > c.NumWorkers
            fprintf('Specified %d workers but only %d available. Setting to max available.\n', ...
                worker_number, c.NumWorkers);
            worker_number = c.NumWorkers;
        end
        
        % Check if a parallel pool exists and delete it
        if ~isempty(gcp('nocreate'))
            fprintf('Deleting existing parallel pool...\n');
            delete(gcp('nocreate'));
        end

        % Create a new parallel pool
        fprintf('Starting parallel pool with %d workers...\n',  worker_number);
        parpool(worker_number);
    end

end