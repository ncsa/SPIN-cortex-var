#!/bin/bash
#set -x

testpath=`pwd`
module load python/2.7.9
stampy_path=/projects/bioinformatics/builds/stampy-1.0.28/stampy.py
ref_path=/projects/bioinformatics/HudsonSoybeanProject/SoybeanAssembly/GCF_000004515.4_Glycine_max_v2.0/GCF_000004515.4_Glycine_max_v2.0.AllChromo.fa
outpath=${testpath}/outputs
vcfdir=${outpath}/vcf_0-i
mkdir -p ${vcfdir}
logpath=${testpath}/PBS/logs
call_file_path=${outpath}/step6_variants
qsubpath=${testpath}/PBS/qsubs

/projects/bioinformatics/builds/stampy-1.0.28/stampy.py -G Gmax /projects/bioinformatics/HudsonSoybeanProject/SoybeanAssembly/GCF_000004515.4_Glycine_max_v2.0/GCF_000004515.4_Glycine_max_v2.0.AllChromo.fa

/projects/bioinformatics/builds/stampy-1.0.28/stampy.py -g Gmax -H Gmax

while read sample
do
	call_file="${call_file_path}/${sample}_0-i_BubbleCaller"
	log_file="${logpath}/CV_Step6_0-i_${sample}.out"
	outvcf="${sample}_0-i"

# call stampy
	nohup /projects/bioinformatics/builds/CORTEX_release_v1.0.5.21/scripts/analyse_variants/process_calls.pl --callfile ${call_file} --callfile_log ${log_file} --outvcf ${outvcf} --outdir ${vcfdir} --samplename_list ${outpath}/sample_list_with_ref --num_cols 6 --stampy_bin ${stampy_path} --stampy_hash ${outpath}/../Gmax --vcftools_dir /projects/bioinformatics/builds/vcftools-0.1.14/vcftools-0.1.14 --kmer 63 --refcol 0 --ploidy 2 --ref_fasta /projects/bioinformatics/HudsonSoybeanProject/SoybeanAssembly/GCF_000004515.4_Glycine_max_v2.0/GCF_000004515.4_Glycine_max_v2.0.AllChromo.fa --caller BC > $sample.mapping.out &

done > ${outpath}/sample_list

