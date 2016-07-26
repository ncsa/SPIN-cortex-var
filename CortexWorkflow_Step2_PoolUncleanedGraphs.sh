#!/bin/bash
#set -x

#echo -e "\n\nSecond Step of the Cortex-var workflow:\n"
#echo    "A graph is built from all uncleaned graphs(binary files), and low coverage nodes will be removed."
#echo -e "We set the threshold to 1. This option can be altered by the user.\n"

#echo    "First input = path to uncleaned graphs" 
#echo -e "Second input = path to output colorlist(a list of list of binary files). Since the cleaned graph will only contain 1 color, the colorlist only contains 1 filelist, which is a list of uncleaned binary(.ctx) files.\n" 

#if [ ! -e $workpath ];
#then 
#    echo "The workpath does not exist, exit."
#    exit 1
#fi

workpath=$1
logspath="${workpath}/PBS/logs"
qsubpath="${workpath}/PBS/qsubs"
outpath=${workpath}/outputs

qsubname="CV_Step2_Pool_Wash"
qsubfile="CortexVar_WorkflowStage2_Pool_Wash.qsub"
`truncate -s 0 ${qsubpath}/${qsubfile}`

echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
#echo "#PBS -W depend=afterok:${qsubpath}/CortexVar_WorkflowStage1_Magellan.qsub"
echo "#PBS -N ${qsubname} " >> ${qsubpath}/${qsubfile}	# set name of jobappend to existing file 
echo "#PBS -l nodes=1:ppn=20,walltime=12:00:00" >> ${qsubpath}/${qsubfile}	# set the number of nodes and processes per node, and max wallclock time
echo "#PBS -M junyuli2@illinois.edu" >> ${qsubpath}/${qsubfile}
echo "#PBS -m ae" >> ${qsubpath}/${qsubfile}	# mail alert at (b)eginning, (e)nd and (a)bortion of execution
echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}	# use bash via a dir
echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}  # specify dir for err files
echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}  # specify dir for output files
echo "#PBS -A aaa" >> ${qsubpath}/${qsubfile}  # specify a local account
echo "#PBS -q big_mem" >> ${qsubpath}/${qsubfile}  # queue name
echo "">>${qsubpath}/${qsubfile}
#echo "Cleaning the pool..."


memprofpath="/scratch/users/kindr/CompGen/Luda/memprof"
cortex_path="/projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/bin/cortex_var_63_c1"

echo "${memprofpath}/memprof.sh ${cortex_path} --kmer_size 63 --mem_height 27 --mem_width 75 --dump_binary ${outpath}/step2_pool_cleaned.ctx --dump_covg_distribution ${outpath}/step2_pool_cleaned.ctx.covg --colour_list ${outpath}/step2_colorlist_uncleaned --remove_low_coverage_supernodes 1" >> ${qsubpath}/${qsubfile}

