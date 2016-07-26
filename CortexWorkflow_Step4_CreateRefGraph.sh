#!/bin/bash
#set -x

# This step creates a reference graph.

ref_file=$1
workpath=$2

#if [ ! -e $workpath ];
#then
#    echo "The workpath does not exist, exit."
#    exit 1
#fi

#if [ -e ${test_path}/ref.k63.ctx ];
#then 
#    echo "ref graph already existed"
#    exit 0
#fi 

logspath="${workpath}/PBS/logs"
`mkdir -p $logspath`
`chmod g=rwx ${logspath}`
qsubpath="${workpath}/PBS/qsubs"
`mkdir -p ${qsubpath}`
`chmod g=rwx ${qsubpath}`
outpath="${workpath}/outputs"
`mkdir -p ${outpath}`
`chmod g=rwx ${outpath}`

memprofpath="/scratch/users/kindr/CompGen/Luda/memprof"
cortex_path="/projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/bin/cortex_var_63_c1"

qsubname="CV_Step4_CreateRefGraph"
qsubfile="CortexVar_WorkflowStage4_CreateRefGraph.qusb"
`truncate -s 0 ${qsubpath}/${qsubfile}`

ref_selist="${outpath}/step4_ref_selist"
echo ${ref_file}>${ref_selist}

echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
echo "#PBS -N ${qsubname} " >> ${qsubpath}/${qsubfile}  # set name of jobappend to existing file 
echo "#PBS -l nodes=1:ppn=20,walltime=12:00:00" >> ${qsubpath}/${qsubfile}      # set the number of nodes and processes per node, and max wallclock time
echo "#PBS -M junyuli2@illinois.edu" >> ${qsubpath}/${qsubfile}
echo "#PBS -m ae" >> ${qsubpath}/${qsubfile}    # mail alert at (b)eginning, (e)nd and (a)bortion of execution
echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}     # use bash via a dir
echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}  # specify dir for err files
echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}  # specify dir for output files
echo "#PBS -A aaa" >> ${qsubpath}/${qsubfile}  # specify a local account
echo "#PBS -q big_mem" >> ${qsubpath}/${qsubfile}  # queue name
echo "">>${qsubpath}/${qsubfile}


echo "${memprofpath}/memprof.sh ${cortex_path} --kmer_size 63 --mem_height 26 --mem_width 75 --se_list ${ref_selist} --dump_binary ${outpath}/G.max.ref.k63.ctx --sample_id G.max">>${qsubpath}/${qsubfile}
