#!/bin/bash
#set -x

# This step creates a reference graph.

ref_path=$1
workpath=$2
cortex_path=$3
cortex_confg=$4
memprof=$5

cortex="${cortex_path}/bin/cortex_var_63_c1"

logspath="${workpath}/PBS/logs"
`mkdir -p $logspath`
`chmod g=rwx ${logspath}`
qsubpath="${workpath}/PBS/qsubs"
`mkdir -p ${qsubpath}`
`chmod g=rwx ${qsubpath}`
outpath="${workpath}/outputs"
`mkdir -p ${outpath}`
`chmod g=rwx ${outpath}`

qsubname="S4_CreateRefGraph_Cortex"
qsubfile="CortexVar_WorkflowStage4_CreateRefGraph.qusb"
`truncate -s 0 ${qsubpath}/${qsubfile}`

ref_selist="${outpath}/step4_ref_selist"
`truncate -s 0 ${ref_selist}`

for chromosome in ${ref_path}/GCF_000004515.4_Glycine_max_v2.0_genomic.*.fna
do
	echo ${chromosome}>>${ref_selist}
done

echo "#!/bin/bash" > ${qsubpath}/${qsubfile}
echo "#PBS -N ${qsubname} " >> ${qsubpath}/${qsubfile}  # set name of jobappend to existing file 
echo "#PBS -S /bin/bash" >> ${qsubpath}/${qsubfile}     # use bash via a dir
echo "#PBS -e ${logspath}/${qsubname}.err" >> ${qsubpath}/${qsubfile}  # specify dir for err files
echo "#PBS -o ${logspath}/${qsubname}.out" >> ${qsubpath}/${qsubfile}  # specify dir for output files
echo "">>${qsubpath}/${qsubfile}


echo "${memprof} ${cortex} ${cortex_confg} --se_list ${ref_selist} --dump_binary ${outpath}/ref.ctx --sample_id ref">>${qsubpath}/${qsubfile}
