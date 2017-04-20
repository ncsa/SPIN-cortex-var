
#echo -e "\n\nFirst Step of the Cortex-var workflow:\n"
#echo    "A graph is built from each sample, with no PCR duplicate removal"
#echo -e "we use quality cutoff of 5. This option can be altered by the user.\n\n"
#echo    "First input = path to input folder" 
#echo -e "Second input = path to output data\n\n" 

datapath=$1 
workpath=$2 
cortex_path=$3
cortex_confg=$4
memprof=$5

quality_score_threshold=5

cortex="${cortex_path}/bin/cortex_var_63_c1"

if [ ! -e $datapath ];
then
    echo "The datapath does not exist, exit."
    exit 1
fi
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
outpath=${workpath}/outputs
`mkdir -p ${outpath}`
`chmod g=rwx ${outpath}`
dump_bin_path="${outpath}/step1_uncleaned_binaries"
`mkdir -p ${dump_bin_path}`
`chmod g=rwx ${dump_bin_path}`


`truncate -s 0 ${outpath}/sample_list`

# 1) if simply go through all samples in certain folder, only one for loop is needed
#	for datafile in ${datapath}/*G*/*fq

# 2) if having a list of sample, located in different subdirectories of $datapath
#	list sample names as an array

sample_alias_list=("U03" "PI518_751" "PI437_169B" "LG03-2979" "PI561_370" "LD00-3309" "PI427_136" "IA" "LG03-3191" "LG05-4292" "TN05-3027" "PI404_188A")

for sample_alias in "${sample_alias_list[@]}"
do
	for datafile in ${datapath}/*G*/*${sample_alias}*	# get all the samples that contain the keyword from the array
	do

    filename=`basename ${datapath}/${datafile}` # basename extracts the name after the last /
    fullname=${filename%_*}
    sample_id=${fullname#*_}
    qsubfile=CortexVar_WorkflowStage1_CreateGraph_${sample_id}.qsub
    qsubname=S1_${sample_id}_Cortex
  
  if grep -Fxq "$sample_id" ${outpath}/sample_list	# if exact same sample name existed in the list. noted the sample_list is also used as an input to further cortex steps

    then
       echo "${datafile}" >> ${outpath}/step1_selist.${sample_id}
 
    else
       echo ${sample_id}>>${outpath}/sample_list
       `truncate -s 0 ${outpath}/step1_selist.${sample_id}` # shrink size to 0 = clear or create a empty file
       echo "${datafile}" >> ${outpath}/step1_selist.${sample_id} 
     
       echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
       echo "#PBS -N ${qsubname}" >> ${qsubpath}/${qsubfile}	# set name of jobappend to existing file 
       echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}	# use bash via a dir
       echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}  # specify dir for err files
       echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}  # specify dir for output files
       echo "">>${qsubpath}/${qsubfile}

#========================================================
       echo "${memprof} ${cortex} ${cortex_confg} --sample_id ${sample_id} --dump_binary ${dump_bin_path}/${sample_id}.ctx --dump_covg_distribution ${dump_bin_path}/${sample_id}.ctx.covg --se_list ${outpath}/step1_selist.${sample_id} --quality_score_threshold ${quality_score_threshold}">>${qsubpath}/${qsubfile}
       # --se_list: input of a list of single-ended fasta/q. created by the follwing echo line.
       # dump a binary called ...ctx   
#========================================================
    fi 
   `chmod g=rw ${qsubpath}/${qsubfile}`
	done
done
