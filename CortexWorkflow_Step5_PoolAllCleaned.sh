#!/bin/bash
#set -x

# Written as described in User Manual 5.1 Example with a trio
workpath=$1

kmer_size=63
mem_width=75
mem_height=26
quality_score_threshold=5

memprofpath="/scratch/users/kindr/CompGen/Luda/memprof"
cortex_path="/projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/bin/cortex_var_63_c6"

if [ ! -e $workpath ];
then
    echo "The workpath does not exist, exit."
    exit 1
fi

logspath="${workpath}/PBS/logs"
`mkdir -p $logspath`
`chmod g=rwx ${logspath}`
qsubpath="${workpath}/PBS/qsubs"
`mkdir -p ${qsubpath}`
`chmod g=rwx ${qsubpath}`
outpath="${workpath}/outputs"
`mkdir -p ${outpath}`
`chmod g=rwx ${outpath}`
cleaned_bin_path=${outpath}/step3_binarylists

sample_list=${outpath}/sample_list

#dump_binary="${workpath}/sample_with_ref.ctx"

qsubfile="CortexVar_WorkflowStage5_PoolAllCleaned.qsub"
qsubname="CV_Step5_PoolAllCleaned"


echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
#for file in "${qsubpath}/*WorkflowStage3*"
#do 
#	echo "#PBS -W depend=afterok:${qsubpath}/${file}"
#done
echo "#PBS -N ${qsubname}" >> ${qsubpath}/${qsubfile}
echo "#PBS -l nodes=1:ppn=20,walltime=12:00:00" >> ${qsubpath}/${qsubfile}
echo "#PBS -M junyuli2@illinois.edu" >> ${qsubpath}/${qsubfile}
echo "#PBS -m ae" >> ${qsubpath}/${qsubfile}
echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}
echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}
echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}
echo "#PBS -A aaa" >> ${qsubpath}/${qsubfile}
echo "#PBS -q big_mem" >> ${qsubpath}/${qsubfile}
echo "">>${qsubpath}/${qsubfile}

#`mkdir -p ${outpath}/step5_binarylists`
#`chmod g=rwx ${outpath}/step5_binarylists`

# Prepare binary and color list for step 5.
`mkdir -p ${outpath}/step5_binarylists`
`chmod g=rwx ${outpath}/step5_binarylists`

# make binary list for every .ctx, each stands for a unique color
echo "echo ${outpath}/step2_pool_cleaned.ctx > ${outpath}/step5_binarylists/step5_binarylist_cleaned.pool" >> ${qsubpath}/${qsubfile}

while read sample
do 
	echo "echo ${cleaned_bin_path}/step3_binarylist.${sample}_cleanedByComparisonToPool.ctx >> ${outpath}/step5_binarylists/step5_binarylist_cleaned.${sample}" >> ${qsubpath}/${qsubfile}

done < ${sample_list}

# make colorlist for cleaned graphs
echo "echo ${outpath}/step5_binarylists/step5_binarylist_cleaned.pool >> ${outpath}/step5_colorlist_cleaned" >> ${qsubpath}/${qsubfile}

while read sample
do
        echo "echo ${outpath}/step5_binarylists/step5_binarylist_cleaned.$sample >> ${outpath}/step5_colorlist_cleaned" >> ${qsubpath}/${qsubfile}

done < ${sample_list}

#echo "ls ${outpath}/step5_binarylists/* >> ${outpath}/step5_colorlist_cleaned"  >> ${qsubpath}/${qsubfile}

echo "echo 'REF' | cat - ${sample_list} > ${sample_list}_with_ref " >> ${qsubpath}/${qsubfile}

echo "${memprofpath}/memprof.sh ${cortex_path} --kmer_size 63 --mem_height 26 --mem_width 75 --colour_list ${outpath}/step5_colorlist_cleaned --dump_binary ${outpath}/final_pool_with_ref.ctx" >> ${qsubpath}/${qsubfile}
