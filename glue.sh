#!/bin/bash
#set -x

datapath=$1
test_path=$2
ref_option=$3
refpath=$4

if [ "$#" -ne 4 ] && [ "$#" -ne 5 ]; then 
	echo "Need 4 inputs. 1) data (fa/fq files) path, 2) test path, 3) ref_option(-r or -g), 4) reference path"
	exit 1;
fi	
# ================= LOCAL CONFIGURATION =====================

pbs_generator_path="/projects/bioinformatics/HudsonSoybeanProject/SoybeanAssemblyOnCortex/Workflow_auto"
common_PBS="-q big_mem -l nodes=1:ppn=20,walltime=24:00:00 -A aaa -M junyuli2@illinois.edu -m ae"

cortex_path="/projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/"
common_cortex="--kmer_size 63 --mem_height 26 --mem_width 75"

memprof=""

# ============================================================

outpath=${test_path}/outputs
`mkdir -p ${outpath}`
`chmod g=rwx ${outpath}`

echo "Step 1: Creating uncleaned binary graphs"
# Input: datapath containing sigle-ended(se) files
# Output: dump_bin_path=${workpath}/outputs/step1_uncleaned_binaries

`${pbs_generator_path}/CortexWorkflow_Step1_CreateUncleanedGraphPerSample.sh ${datapath} ${test_path} ${cortex_path} "${common_cortex}" ${memprof}`

`truncate -s 0 ${outpath}/stage1_list`

for file in ${test_path}/PBS/qsubs/*WorkflowStage1*.qsub
do
	step1=$(qsub ${common_PBS} ${file})
	echo $step1
	printf :$step1 >> ${outpath}/stage1_list
done

echo "Step 2: Pool the uncleaned graphs and remove low-coverage nodes"
# Input: ${workpath} 
# Output: ${test_path}/step2_pool_cleaned.ctx

`${pbs_generator_path}/CortexWorkflow_Step2_PoolUncleanedGraphs.sh ${test_path} ${cortex_path} "${common_cortex}" ${memprof}`

all_step1=`cat ${outpath}/stage1_list`
step2=$(qsub ${common_PBS} -W depend=afterok$all_step1 ${test_path}/PBS/qsubs/CortexVar_WorkflowStage2_Pool_Wash.qsub)
echo $step2

echo "Step 3: Cleaning the binaries by comparing with the cleaned pool"

`${pbs_generator_path}/CortexWorkflow_Step3_CleanGraphPerSample.sh ${test_path} ${outpath}/step2_pool_cleaned.ctx ${cortex_path} "${common_cortex}" ${memprof}`

`truncate -s 0 ${outpath}/stage3_list`

for file in ${test_path}/PBS/qsubs/*Stage3*
do 
	step3=$(qsub ${common_PBS} -W depend=afterok:$step2 ${file})
	echo $step3
	printf :$step3 >> ${outpath}/stage3_list
done


if [ $3 == "-r" ]; then                                                           	
	echo "Step 4: Create a reference graph"
	# Input: se_list of ref(refpath)
	# Output: ref.${sample_id}.k63.ctx in ${workpath}(test folder)

	`${pbs_generator_path}/CortexWorkflow_Step4_CreateRefGraph.sh ${refpath} ${test_path} ${cortex_path} "${common_cortex}" ${memprof}`
	
	step4=$(qsub ${common_PBS} ${test_path}/PBS/qsubs/CortexVar_WorkflowStage4_CreateRefGraph.qusb)
	echo $step4
	#ref_sample_id=`basename ${refpath}`  
	ref_graph=${outpath}/ref.ctx 
	#need modification for flexibility  here
fi

if [ $3 == "-g" ]; then	
	ref_graph=$4
	step4=$step3
fi

echo "Step 5: Pool reference graph with cleaned graphs and cleaned pool"
# Input: testpath as data/work path and reference graph generated in step4
# Output: multicolor graph 

# add ref graph to colorlist for pooling
echo ${ref_graph} > ${outpath}/step5_binarylist.REF
echo ${outpath}/step5_binarylist.REF > ${outpath}/step5_colorlist_cleaned

all_step3=`cat ${outpath}/stage3_list`
`${pbs_generator_path}/CortexWorkflow_Step5_PoolAllCleaned.sh ${test_path} ${cortex_path} "${common_cortex}" ${memprof}`
step5=$(qsub ${common_PBS} -W depend=afterok:$step4${all_step3} ${test_path}/PBS/qsubs/CortexVar_WorkflowStage5_PoolAllCleaned.qsub)
echo $step5

echo "Step 6: Call variants"
# Input: testpath as data/work path and cleaned pool generated in step5
#`${pbs_generator_path}/CortexWorkflow_Step6_0-i_BubbleCaller.sh ${test_path} ${outpath}/final_pool_with_ref.ctx ${cortex_path} "${common_cortex}" ${memprof}`
`${pbs_generator_path}/CortexWorkflow_Step6_i-i_BubbleCaller.sh ${test_path} ${outpath}/final_pool_with_ref.ctx ${cortex_path} "${common_cortex}" ${memprof}`

for file in ${test_path}/PBS/qsubs/*Stage6*
do
        step6=$(qsub ${common_PBS} -W depend=afterok:$step5 ${file})
        echo $step6
done

