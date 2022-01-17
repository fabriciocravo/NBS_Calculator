# Network-Based Inferential Procedures & Empirical Benchmarking

**NOTE:** The main repository has been updated to reflect recent benchmarking and summarization procedures of 01/01/2022. For previous version, see branch "old-master".

Purpose:
1. Perform inference in networks at various scales and from the Matlab command line
2. Empirically benchmark and compare performance of inferential procedures

Inferential procedures currently include:
- edge-level: Bonferroni (FWER)
- edge-level: Storey (FDR)
- component/cluster-level: Network-Based Statistic (NBS; FWER; Options: Size or Intensity; Zalesky, Fornito, & Bullmore, 2010)
- component/cluster-level: Threshold-Free Cluster Enhancement (TFCE; FWER; Smith & Nichols, 2009)
- network-level: Constrained NBS (cNBS; FWER)
- network-level: Constrained NBS (FDR)
- whole brain-level/omnibus: Options: Threshold_Positive, Threshold_Both_Dir, Average_Positive, Average_Both_Dir, Multidimensional_cNBS, Multidimensional_all_edges

Note: All procedures besides NBS are implemented here (so any mistakes are mine!), relying in part on underlying functionality in the NBS toolbox (see NBS_addon). cNBS and multidimensional cNBS are introduced here (Noble & Scheinost, 2020).

## Getting Started

### Prerequisites

Matlab
NBS toolbox: https://sites.google.com/site/bctnet/comparison/nbs

### Usage

#### Network-Based Inference

1. Set paths and parameters in setparams.m
    - Example material for testing can be found in the NBS toolbox and NBS_benchmarking toolbox (this toolbox):
        - NBS toolbox "SchizophreniaExample" directory: example data and design matrix for schizophrenia study
        - NBS_benchmarking toolbox "NBS_addon" directory: simple and Shen edge groups
2. Run run_NBS_cl.m (must be on your path or in the working directory)
3. View results are all in the nbs variable (e.g., p-values are in nbs.NBS.pval). A sample visualization of the results is provided for cNBS.

#### Empirical Benchmarking of Accuracy Metrics

1. Set paths and parameters
    - Set script and data paths in setparams_bench.m
        - Optional: If want system-dependent paths, set paths for each system in setpaths.m. Must set system_dependent_paths=1 in setparams_bench.m to use. This will overwrite paths in setparams_bench.m, so no need to set paths in setparams_bench.m.
    - Set parameters and script/data paths in setparams_bench.m (e.g., do_TPR, use_both_tasks, etc.)
2. Run resampling procedure
    - Run run_benchmarking.m
3. Calculate ground truth
    - Set task_gt in setparams_bench.m
    - Run calculate_ground_truth.m 
3. Summarize accuracy & other results
    - Set parameters for resampling results to be summarized in setparams_summary.m
    - If doing summary from another workstation, mount these directories and re-define paths for resampling results and ground truth data paths. This is where system_dependent_paths will come in handy (see Step 1.)
    - Set date/time info for resampling results to be summarized in set_datetimestr_and_files.m
    - Run summarize_tprs.m or summarize_fprs.m

### References

- Zalesky, A., Fornito, A. and Bullmore, E.T., 2010. Network-based statistic: identifying differences in brain networks. Neuroimage, 53(4), pp.1197-1207.

- Smith, S.M. and Nichols, T.E., 2009. Threshold-free cluster enhancement: addressing problems of smoothing, threshold dependence and localisation in cluster inference. Neuroimage, 44(1), pp.83-98.

- Noble, S. and Scheinost, D., 2020. The Constrained Network-Based Statistic: A New Level of Inference for Neuroimaging. In International Conference on Medical Image Computing and Computer-Assisted Intervention (pp. 458-468). Springer, Cham.

