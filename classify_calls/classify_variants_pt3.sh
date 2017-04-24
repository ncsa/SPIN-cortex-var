#!/bin/bash
#PBS -N 
#PBS -l 
#PBS -M 
#PBS -m 
#PBS -S /bin/bash
#PBS -A 
#PBS -q 


#Edit this qsub script with the datapath (path to cortex run), and number of samples

num_samples=

num_colors=$(($num_samples + 2))

module load R

#I just changed this to a qsub format, so the datapath I entered manually in the script
datapath=/projects/bioinformatics/HudsonSoybeanProject/SoybeanAssemblyOnCortex/HighCovgSamples.Dec20_2016

files=$(ls -1 ${datapath}/outputs/step6_PathDivergence | grep "out_pd_calls" | sed "s/.out_pd_calls//")


for file in $files
do
	echo $file
	num_variants=$(wc -l ${datapath}/outputs/step6_PathDivergence/classified_calls/${file}.out_pd_calls.covg_for_classifier | sed 's/ /\t/' | cut -f1)
	echo $num_variants
	cat /projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/scripts/analyse_variants/classifier.parallel.ploidy_aware.R  | R --vanilla --args 1 ${num_variants} ${datapath}/outputs/step6_PathDivergence/classified_calls/${file}.out_pd_calls.covg_for_classifier ${num_variants} ${num_colors} 1 ${datapath}/outputs/step6_PathDivergence/classified_calls/${file}.log.table 1100000000 63 2 ${datapath}/outputs/step6_PathDivergence/classified_calls/${file}.out_pd_calls_classified 
done	
