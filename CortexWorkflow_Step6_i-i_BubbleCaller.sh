#!/bin/bash
#set -x

workpath=$1
merged_clean_pool_path=$2

kmer_size=63
mem_width=75
mem_height=26
quality_score_threshold=5

memprofpath="/scratch/users/kindr/CompGen/Luda/memprof"
cortex_path="/projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/bin/cortex_var_63_c6"

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

#for datafile in ${workpath}/PBS/qsubs/*Stage1*
#do

color_id=1

#sample_list=${outpath}/sample_list

while read sample_id
do
       qsubfile=CortexVar_WorkflowStage6_i-i_${sample_id}.qsub
       qsubname=CV_Step6_i-i_${sample_id}
      
       echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
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
#========================================================             
#CORTEX:     
       echo "${memprofpath}/memprof.sh ${cortex_path} --kmer_size ${kmer_size} --mem_height ${mem_height} --mem_width ${mem_width} --multicolour_bin ${merged_clean_pool_path} --detect_bubbles1 ${color_id}/${color_id} --output_bubbles1 ${workpath}/outputs/step6_variants/${sample_id}_i-i_BubbleCaller --print_colour_coverages" >> ${qsubpath}/${qsubfile}
       #  find bubbles in the graph where both branches/sides of the bubbles are present in colour 0
       #  --detect_bubbles1 arg1/arg2 (arg1 and arg2 are comma-separated lists of colours (numbers from 0 to C-1))

#========================================================      
    `chmod g=rw ${qsubpath}/${qsubfile}`
    ((color_id++))

done < ${outpath}/sample_list

