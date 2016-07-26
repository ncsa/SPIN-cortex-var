#!/bin/bash
#set -x

#if [ "$#" -ne 2 ]
#then
#    echo -e "\n\nIllegal number of parameters"
#    echo "first input = datapath"
#    echo "second input = merged cleaned pool path"
#
#   exit 1;
#fi
workpath=$1
cleaned_pool_path=$2

kmer_size=63
mem_width=75
mem_height=26
quality_score_threshold=5

memprofpath="/scratch/users/kindr/CompGen/Luda/memprof"
cortex_path="/projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/bin/cortex_var_63_c2"

if [ ! -e $workpath ];
then 
    echo "The workpath does not exist, exit."
    exit 1
fi

logspath="${workpath}/PBS/logs"
`mkdir -p "$logspath"`
`chmod g=rwx ${logspath}`
qsubpath="${workpath}/PBS/qsubs"
`mkdir -p "$qsubpath"`
`chmod g=rwx "$qsubpath"`
outpath=${workpath}/outputs
`mkdir -p "$outpath"`
`chmod g=rwx "$outpath"`
uncleaned_bin_path="${outpath}/step1_uncleaned_binaries"
`mkdir -p "$uncleaned_bin_path"`
`chmod g=rwx "$uncleaned_bin_path"`

binlist_path="${outpath}/step3_binarylists"
`mkdir -p ${binlist_path}`
`chmod g=rwx ${binlist_path}`

colorlist_path="${outpath}/step3_colorlists"
`mkdir -p "${colorlist_path}"`
`chmod g=rwx "${colorlist_path}"`

sample_list=${outpath}/sample_list

while read line
do
       sample_id=$line
       qsubfile=CortexVar_WorkflowStage3_${sample_id}.qsub
       qsubname=CV_Step3_${sample_id}

       echo "#!/bin/bash" > "${qsubpath}/${qsubfile}"
       #echo "#PBS -W depend=afterok:${qsubpath}/CortexVar_WorkflowStage2_Pool_Wash.qsub" >> ${qsubpath}/${qsubfile} 
       echo "#PBS -N ${qsubname}" >> "${qsubpath}/${qsubfile}"
       echo "#PBS -l nodes=1:ppn=20,walltime=12:00:00" >> "${qsubpath}/${qsubfile}"
       echo "#PBS -M junyuli2@illinois.edu" >> ${qsubpath}/${qsubfile}
       echo "#PBS -m ae" >> ${qsubpath}/${qsubfile}
       echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}
       echo "#PBS -e ${logspath}/${qsubname}.err" >> "${qsubpath}/${qsubfile}"
       echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}
       echo "#PBS -A aaa" >> ${qsubpath}/${qsubfile}
       echo "#PBS -q big_mem" >> ${qsubpath}/${qsubfile}
       echo "">>${qsubpath}/${qsubfile}
       #echo " creating qsubs for sample ${sample_id} "

       uncleaned_binary=${uncleaned_bin_path}/${sample_id}.ctx
#========================================================      
       `truncate -s 0 ${colorlist_path}/step3_colorlist.${sample_id}`
       `truncate -s 0 ${binlist_path}/step3_binarylist.pool_cleaned`
       `truncate -s 0 ${binlist_path}/step3_binarylist.${sample_id}`

       echo "${cleaned_pool_path}" >> ${binlist_path}/step3_binarylist.pool_cleaned
       echo "${uncleaned_binary}" >> ${binlist_path}/step3_binarylist.${sample_id}
       echo "${binlist_path}/step3_binarylist.pool_cleaned" >> ${colorlist_path}/step3_colorlist.${sample_id}
       echo "${binlist_path}/step3_binarylist.${sample_id}" >> ${colorlist_path}/step3_colorlist.${sample_id}      
#========================================================
#CORTEX:     
       echo "${memprofpath}/memprof.sh ${cortex_path} --kmer_size ${kmer_size} --mem_height ${mem_height} --mem_width ${mem_width} --multicolour_bin ${cleaned_pool_path} --colour_list ${colorlist_path}/step3_colorlist.${sample_id} --load_colours_only_where_overlap_clean_colour 0 --successively_dump_cleaned_colours cleanedByComparisonToPool">>${qsubpath}/${qsubfile}
# Each cleaned binary is dumped in the same directory as its corresponding unclean binary, with cleanedByComparisonToPool as suffix.
# Error-correction of low-coverage data
#========================================================
  #  fi 
    #echo "${datafile}" >> ${outpath}/${sample_id}_se
    `chmod g=rwx ${qsubpath}/${qsubfile}`

done < ${sample_list}
