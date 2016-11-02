# SPIN-cortex-var
Cortex_var workflow in bash for SPIN

Directories: 
    TEST/
    ├── outputs
    │   ├── ref.ctx
    │   ├── sample_list
    │   ├── stage1_list
    │   ├── stage3_list
    │   ├── step1_selist.SAMPLE1
    │   ├── step1_selist.SAMPLE2...
    │   ├── step1_uncleaned_binaries
    │   ├── step2_binarylist_uncleaned
    │   ├── step2_colorlist_uncleaned
    │   ├── step3_binarylists
    │   ├── step3_colorlists
    │   ├── step4_ref_selist
    │   ├── step5_binarylist.REF
    │   ├── step5_binarylists
    │   ├── step5_colorlist_cleaned
    │   └── step6_variants
    └── PBS
        ├── logs
        └── qsubs

===============================
Configurations:
    glue.sh: everything in the "==== LOCAL CONFIGURATION ====" section:
        1) pbs_generator_path: directory of workflow scripts (where this README is)
        2) common_PBS: the PBS parameters shared by all the steps in the workflow
        3) cortex_path: direcotory of the software package
        4) common_cortex: the cortex parameters shared by all the steps
        5) (optional) memprof: resource usage record software

    CortexWorkflow_Step1_CreateUncleanedGraphPerSample.sh: 
        1) line 46: for datafile in ${datapath}/*fq
            -> ${datapath} will be read from your command line input. Modify the line according to your fasta/q file nomination so that the loop goes through the fasta files of each sample in this folder.
        2) (optional) line 14: quality_score_threshold=5
    
    CortexWorkflow_Step5_PoolAllCleaned.sh:
        line 12: cortex=${cortex_path}/bin/cortex_var_63_c4
            -> change the last digit to (SAMPLE_NUMBER + 2)    # ex. using 42 samples, this line should be cortex=${cortex_path}/bin/cortex_var_63_c44

    CortexWorkflow_Step6_i-i_BubbleCaller.sh:
        line 12: same as above

    Then, go to CORTEX package folder, type: 
        make MAXK=63 cortex_var
        make MAXK=63 NUM_COLS=1 cortex_var
        make MAXK=63 NUM_COLS=2 cortex_var
        make MAXK=63 NUM_COLS=(SAMPLE_NUMBE+2) cortex_var   # ex. using 42 samples, make MAXK=63 NUM_COLS=44 cortex_var

===============================
Running:
    glue.sh followed by 1) datapath(direcotry of fa/fq files), 2) test path(working directory), 3) reference option(-r or -g), 4) reference fq file or existed reference path

# reference option: -r for first time using the reference. Step4 generating reference graph will be executed.
                    -g for using existed reference graph (ref.ctx) for new runs. Step4 will be skiped. 

===============================
Useful directories:
    /PBS/logs   # PBS errpr and output logs. Runtime and cortex output infomation can be found here.
    /PBS/qsubs  # content of submitted jobs."CV"==Cortex-var

    /outputs/step6_variants     # Bubble Caller and Path Divergence outputs
