
#echo -e "\n\nFirst Step of the Cortex-var workflow:\n"
#echo    "A graph is built from each sample, with no PCR duplicate removal"
#echo -e "we use quality cutoff of 5. This option can be altered by the user.\n\n"
#echo    "First input = path to input folder" 
#echo -e "Second input = path to output data\n\n" 

datapath=$1 
workpath=$2 

kmer_size=63
mem_width=75
mem_height=26
quality_score_threshold=5

memprofpath="/scratch/users/kindr/CompGen/Luda/memprof"

#CORTEX: kmer is 63, 1 color in the graph
cortex_path="/projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/bin/cortex_var_63_c1"

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
`chmod g=rwx ${logspath}`		# permission
qsubpath="${workpath}/PBS/qsubs"
`mkdir -p ${qsubpath}`
`chmod g=rwx ${qsubpath}`
#file_lists="${workpath}/file_lists"
#`mkdir -p ${file_lists}`
#`chmod g=rwx ${file_lists}`
outpath=${workpath}/outputs
`mkdir -p ${outpath}`
`chmod g=rwx ${outpath}`
dump_bin_path="${outpath}/step1_uncleaned_binaries"
`mkdir -p ${dump_bin_path}`
`chmod g=rwx ${dump_bin_path}`

#if [ ! -e ${dump_bin}/${kmer_size} ]
#then 
#    echo "The dump_bin path is not existed, creating it."
#fi

#dump_bin_path="${dump_bin}/${kmer_size}"
#`mkdir -p ${dump_bin_path}`
#`chmod g=rwx ${dump_bin_path}`

`truncate -s 0 ${outpath}/sample_list`

for datafile in ${datapath}/*
do
    filename=`basename ${datapath}/${datafile}` # basename extracts the name after the last /
    buffer=${filename%.*} # regardless of suffix??   # ex. x=file.c  echo ${x%.c}.o  --> file.o
    num=${buffer##*d} # count the occurence of 'd' in {buffer}

    if [ "${num}" == "1" ];
    then
       name1=${filename%_*}
       sample_id=${name1#*_}
       echo ${sample_id}>>${outpath}/sample_list
    fi
    `truncate -s 0 ${outpath}/step1_selist.${sample_id}` # shrink size to 0 = clear or create a empty file
done

for datafile in ${datapath}/*
do
    filename=`basename ${datapath}/${datafile}`	
    buffer=${filename%.*} 
    num=${buffer##*d}
    
    if [ "${num}" == "1" ];
    then
       name1=${filename%_*}
       sample_id=${name1#*_}
       qsubfile=CortexVar_WorkflowStage1_CreateGraph_${sample_id}.qsub
       qsubname=CV_Step1_${sample_id}
 
       echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
       echo "#PBS -N ${qsubname}" >> ${qsubpath}/${qsubfile}	# set name of jobappend to existing file 
       echo "#PBS -l nodes=1:ppn=20,walltime=12:00:00" >> ${qsubpath}/${qsubfile}	# set the number of nodes and processes per node, and max wallclock time
       echo "#PBS -M junyuli2@illinois.edu" >> ${qsubpath}/${qsubfile}
       echo "#PBS -m ae" >> ${qsubpath}/${qsubfile}	# mail alert at (b)eginning, (e)nd and (a)bortion of execution
       echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}	# use bash via a dir
       echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}  # specify dir for err files
       echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}  # specify dir for output files
       echo "#PBS -A aaa" >> ${qsubpath}/${qsubfile}  # specify a local account
       echo "#PBS -q big_mem" >> ${qsubpath}/${qsubfile}  # queue name
       echo "">>${qsubpath}/${qsubfile}
       #echo " creating qsubs for sample ${sample_id} "

       #dump_binary=${dump_bin_path}/${sample_id}.unclean.kmer${kmer_size}.q${quality_score_threshold}.Mem_h${mem_height}_w${mem_width}.ctx
      # if [ -e ${dump_binary} ];
      # then
      #     `rm ${dump_binary}`
      # fi
#========================================================
       echo "${memprofpath}/memprof.sh ${cortex_path} --sample_id ${sample_id} --kmer_size ${kmer_size} --mem_height ${mem_height} --mem_width ${mem_width} --dump_binary ${dump_bin_path}/${sample_id}.ctx --dump_covg_distribution ${dump_bin_path}/${sample_id}.ctx.covg --se_list ${outpath}/step1_selist.${sample_id} --quality_score_threshold ${quality_score_threshold}">>${qsubpath}/${qsubfile}
       # --se_list: input of a list of single-ended fasta/q. created by the follwing echo line.
       # dump a binary called ...ctx   
#========================================================
    fi 
    echo "${datafile}" >> ${outpath}/step1_selist.${sample_id}
    `chmod g=rw ${qsubpath}/${qsubfile}`
    done

`truncate -s 0 ${outpath}/step2_binarylist_uncleaned`
`truncate -s 0 ${outpath}/step2_colorlist_uncleaned`

# creating a filelist that lists uncleaned binary files
echo "ls ${dump_bin_path}/*.ctx >> ${outpath}/step2_binarylist_uncleaned">>${qsubpath}/${qsubfile}

# creating the colorlist that contains the filelist
echo "echo ${outpath}/step2_binarylist_uncleaned >> ${outpath}/step2_colorlist_uncleaned">>${qsubpath}/${qsubfile}

