#!/bin/bash
#set -x

workpath=$1
cortex_path=$2
cortex_confg=$3
memprof=$4

quality_score_threshold=5

cortex="${cortex_path}/bin/cortex_var_63_c15"

logspath="${workpath}/PBS/logs"
`mkdir -p $logspath`
`chmod g=rwx ${logspath}`
qsubpath="${workpath}/PBS/qsubs"
`mkdir -p ${qsubpath}`
`chmod g=rwx ${qsubpath}`
outpath="${workpath}/outputs/"
`mkdir -p ${outpath}`
`chmod g=rwx ${outpath}`

`mkdir -p ${workpath}/outputs/step6_PathDivergence`
`chmod g=rwx ${workpath}/outputs/step6_PathDivergence`

merged_clean_pool_path="${outpath}/final_pool_with_ref.ctx"
ref_list="${outpath}/step4_ref_selist"

color_id=2   # color_id of pool is 1, of 1st sample is 2.

while read sample_id
do
       qsubfile=CortexVar_WorkflowStage6_PathDivergence_${sample_id}.qsub
       qsubname=S6_${sample_id}_PD_Cortex
      
       echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
       echo "#PBS -N ${qsubname}" >> ${qsubpath}/${qsubfile}
       echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}
       echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}
       echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}
       echo "">>${qsubpath}/${qsubfile}
#========================================================             
#CORTEX:     

	echo "${memprof} ${cortex} ${cortex_confg} --multicolour_bin ${merged_clean_pool_path} --path_divergence_caller ${color_id} --ref_colour 0 --list_ref_fasta ${ref_list} --path_divergence_caller_output ${outpath}/step6_PathDivergence/${sample_id}.out --print_colour_coverages" >> ${qsubpath}/${qsubfile}


#========================================================      
    `chmod g=rw ${qsubpath}/${qsubfile}`
    ((color_id++))

done < ${outpath}/sample_list

