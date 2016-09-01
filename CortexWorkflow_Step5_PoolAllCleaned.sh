#!/bin/bash
#set -x

# Written as described in User Manual 5.1 Example with a trio
workpath=$1
cortex_path=$2
cortex_confg=$3
memprof=$4

quality_score_threshold=5

cortex=${cortex_path}/bin/cortex_var_63_c4

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


qsubfile="CortexVar_WorkflowStage5_PoolAllCleaned.qsub"
qsubname="CV_Step5_PoolAllCleaned"


echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
echo "#PBS -N ${qsubname}" >> ${qsubpath}/${qsubfile}
echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}
echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}
echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}
echo "">>${qsubpath}/${qsubfile}


# Prepare binary and color list for step 5.
`mkdir -p ${outpath}/step5_binarylists`
`chmod g=rwx ${outpath}/step5_binarylists`

# make binary list for every .ctx, each stands for a unique color
echo "echo ${outpath}/step2_pool_cleaned.ctx > ${outpath}/step5_binarylists/step5_binarylist_cleaned.pool" >> ${qsubpath}/${qsubfile}

while read sample
do 
	echo "echo ${cleaned_bin_path}/step3_binarylist.${sample}_cleanedByComparisonToPool.ctx > ${outpath}/step5_binarylists/step5_binarylist_cleaned.${sample}" >> ${qsubpath}/${qsubfile}

done < ${sample_list}

# make colorlist for cleaned graphs
echo "echo ${outpath}/step5_binarylists/step5_binarylist_cleaned.pool > ${outpath}/step5_colorlist_cleaned" >> ${qsubpath}/${qsubfile}

while read sample
do
        echo "echo ${outpath}/step5_binarylists/step5_binarylist_cleaned.$sample >> ${outpath}/step5_colorlist_cleaned" >> ${qsubpath}/${qsubfile}

done < ${sample_list}

#echo "ls ${outpath}/step5_binarylists/* >> ${outpath}/step5_colorlist_cleaned"  >> ${qsubpath}/${qsubfile}

echo "echo 'REF' | cat - ${sample_list} > ${sample_list}_with_ref " >> ${qsubpath}/${qsubfile}

echo "${memprof} ${cortex} ${cortex_confg} --colour_list ${outpath}/step5_colorlist_cleaned --dump_binary ${outpath}/final_pool_with_ref.ctx" >> ${qsubpath}/${qsubfile}
