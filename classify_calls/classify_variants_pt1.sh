#!/bin/bash


#Data path is the path the folder from the latest Cortex run

datapath=$1

#making output directory for the classified calls files in the cortex output calls directory
mkdir $datapath/outputs/step6_PathDivergence/classified_calls

#may neeed to update datapath

files=$(ls -1 ${datapath}/outputs/step6_PathDivergence | grep "out_pd_calls" | sed "s/.out_pd_calls//")

for file in $files
do 
	echo $file
	perl /projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/scripts/analyse_variants/make_read_len_and_total_seq_table.pl ${datapath}/PBS/logs/S6_${file}_PD_Cortex.out >& $datapath/outputs/step6_PathDivergence/classified_calls/${file}.log.table	
done


	

