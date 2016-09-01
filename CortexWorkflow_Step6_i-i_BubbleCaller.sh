#!/bin/bash
#set -x

workpath=$1
merged_clean_pool_path=$2
cortex_path=$3
cortex_confg=$4
memprof=$5

quality_score_threshold=5

cortex="${cortex_path}/bin/cortex_var_63_c4"

logspath="${workpath}/PBS/logs"
`mkdir -p $logspath`
`chmod g=rwx ${logspath}`
qsubpath="${workpath}/PBS/qsubs"
`mkdir -p ${qsubpath}`
`chmod g=rwx ${qsubpath}`
outpath="${workpath}/outputs/"
`mkdir -p ${outpath}`
`chmod g=rwx ${outpath}`

`mkdir -p ${workpath}/outputs/step6_variants`
`chmod g=rwx ${workpath}/outputs/step6_variants`


color_id=2   # color_id of pool is 1, of 1st sample is 2.

while read sample_id
do
       qsubfile=CortexVar_WorkflowStage6_i-i_${sample_id}.qsub
       qsubname=CV_Step6_i-i_${sample_id}
      
       echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
       echo "#PBS -N ${qsubname}" >> ${qsubpath}/${qsubfile}
       echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}
       echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}
       echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}
       echo "">>${qsubpath}/${qsubfile}
#========================================================             
#CORTEX:     
       echo "${memprof} ${cortex} ${cortex_confg} --multicolour_bin ${merged_clean_pool_path} --detect_bubbles1 ${color_id}/${color_id} --output_bubbles1 ${workpath}/outputs/step6_variants/${sample_id}_i-i_BubbleCaller --print_colour_coverages" >> ${qsubpath}/${qsubfile}
       #  find bubbles in the graph where both branches/sides of the bubbles are present in colour 0
       #  --detect_bubbles1 arg1/arg2 (arg1 and arg2 are comma-separated lists of colours (numbers from 0 to C-1))

#========================================================      
    `chmod g=rw ${qsubpath}/${qsubfile}`
    ((color_id++))

done < ${outpath}/sample_list

