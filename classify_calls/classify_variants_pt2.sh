#!/bin/bash

datapath=$1

num_samples=$2

files=$(ls -1 ${datapath}/outputs/step6_PathDivergence | grep "out_pd_calls" | sed "s/.out_pd_calls//")

num_colors=$(($num_samples + 2)) #the reference color and the pool color are added

for file in $files
do
	echo $file
	perl /projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/scripts/analyse_variants/make_covg_file.pl ${datapath}/outputs/step6_PathDivergence/${file}.out_pd_calls ${num_colors} 0 
done
