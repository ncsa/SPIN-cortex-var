#!/bin/bash

#This script will loop over all the samples in $files and extract the repeat variants from the classfied variants file, and then grep for the repeats sequences in the path divergence output file

#$PD_output should be to the path diverence output of this Cortex run

#output of this script is 2 fasta files for each sample, one containing the branch1 sequences of the cortex calls specified, and one containing the branch2 sequences of the cortex calls specified

#######Currently, for the python scripts to work with Anisimov launcer, they need to be in the same directory as the outputdir specified###########


##############
####STEP 1####
##############

#command line variables
PD_output=$1 #path to path divergence output

#output directory for this run
directory=$2

#Path to the classified variants TSV files generated in the last Cortex step
classified_calls=$3

#number of samples
num_samples=$4

#full path to reference genome fasta
reference_genome=$5

files=$(ls -1 $PD_output | grep "out_pd_calls" | sed "s/.out_pd_calls//") #these file extensions are assigned by Cortex, so I'll leave them hardcoded

#delete temporary directories if present
rm -rf $directory/anisimov_containers
rm -rf $directory/repeats_and_vars
rm -rf $directory/Cortex_calls_only_sequences

#creating an output directory for the extracted repeat variants in the path divergence output directory
mkdir $directory/repeats_and_vars

#create directory with files containing only the sequences from cortex output
mkdir $directory/Cortex_calls_only_sequences

#loop over files to extract repeats_and_vars from classified file, and extract sequences from the PDoutput file
for file in $files
do
	echo "extracting repeats_and_varss for $file"
	grep -v "error" $classified_calls/${file}.out_pd_calls_classified > $directory/repeats_and_vars/${file}.repeats_and_vars
	#add an underscore to the repeat variants for no ambiguity 
	sed -i -r -e 's/(var_[0-9]+)/\1_/' $directory/repeats_and_vars/${file}.repeats_and_vars #add in an underscore after call number, makes later steps easier
	sed -i -r -e 's/ //' $directory/repeats_and_vars/${file}.repeats_and_vars 
	grep --no-group-separator -A1 ">" $PD_output/${file}.out_pd_calls  > $directory/Cortex_calls_only_sequences/${file}.PD_calls_sequences #make file containing only sequences for easier parsing
done


##############
####STEP 2####
##############

#For some reason, I have not been able to get individual python scripts to run in the background, I am using Anisimov launcher to do that here 

#creating file that executes a pythons script to produce a fasta file of the branch1 and branch2 sequences


#output for the fasta file for each sample
mkdir $directory/repeats_and_vars/fastas

#make the executable grep scripts for each sample in its own directory to be of use in Anisimov launcher, and then add this script the Joblist file required by the launcher
mkdir $directory/anisimov_containers
touch $directory/anisimov_containers/JobList.txt #create joblist file
for file in $files
do
	echo "making anisimov executable script for ${file}"
	mkdir $directory/anisimov_containers/${file}
	touch $directory/anisimov_containers/${file}/${file}.extract_seqs #make executable script
	call_type_file=$directory/repeats_and_vars/${file}.repeats_and_vars #file for sample created in step1
	new_file=$directory/anisimov_containers/${file}/${file}.extract_seqs #this is the individual executable for each files grep job..now to write to it
	echo "#!/bin/bash" > $new_file #adding shebang line to file
	echo "$directory/make_fasta.py -seqs $directory/Cortex_calls_only_sequences/${file}.PD_calls_sequences -calls $directory/repeats_and_vars/${file}.repeats_and_vars -o $directory/repeats_and_vars/fastas/${file}_repeats_and_vars.fa" >> $new_file
	echo "$directory/anisimov_containers/${file} ${file}.extract_seqs" >> $directory/anisimov_containers/JobList.txt #adding file to JobLIst in required format
done		
#echo -e allows echo to interpret the escape character '\'

#Execute Anisimov Launchcher to send each script to one core, so each single threaded grep job will be done on the same node

module load intel/12.0.4
module load openmpi-1.4.3-intel-12.0.4


cores=$(($num_samples + 1)) #add extra core to pass into launcher because lancher needs one
echo $cores
mpiexec -n ${cores} --bycore -machinefile ${PBS_NODEFILE} /projects/bioinformatics/builds/AnisimovLauncher/scheduler.x $directory/anisimov_containers/JobList.txt /bin/bash > $directory/scheduler.log


##############
####STEP 3####
##############

#This step will blast the repeat fasta files against the reference genome specified, the output will be an XML BLAST output for use in biopython, and an plaintext blast, for human readability. 

#Make a blast database of the refernce genome specified, the database files will be output in the dir of the reference fasta
module load /usr/local/apps/bioapps/modules/blast/blast-2.5.0+

makeblastdb -in ${reference_genome} -dbtype nucl -out ${reference_genome}.database

#blast each samples fasta against the reference 
fasta_path=$directory/repeats_and_vars/fastas

#I am going to submit each samples blast background jobs 
#The blast files will be output in a directory "blast_results" in the parent directory, fasta

mkdir $fasta_path/blast_results

for file in $files
do
#	#blast XML output
	echo "Blasting ${file}"
	blastn -db ${reference_genome}.database -query $fasta_path/${file}_repeats_and_vars.fa -max_hsps 100 -outfmt 5 -out $fasta_path/blast_results/${file}_repeats_and_vars.blast_result.xml &
	#blast plaintext output
	blastn -db ${reference_genome}.database -query $fasta_path/${file}_repeats_and_vars.fa -max_hsps 100 -out $fasta_path/blast_results/${file}_repeats_and_vars.blast_result.txt &
done

wait;

##############
####STEP 4####
##############

#This step will parse the BLAST output with biopython for the number of BLAST hits, the top BLAST hit coordinate on the reference, sequence lengths, GC content, and sequence entropy

#I need to create the anisimov lancher files again to run a python script per sample per core
rm -rf $directory/anisimov_containers
mkdir $directory/anisimov_containers
touch $directory/anisimov_containers/JobList.txt #create joblist file

mkdir $directory/blasted_and_parsed_cortex_calls

for file in $files
do
        echo "making anisimov executable script for ${file}"
        mkdir $directory/anisimov_containers/${file}
        touch $directory/anisimov_containers/${file}/${file}.parsing #make executable script that contains the python script
	new_file=$directory/anisimov_containers/${file}/${file}.parsing
	echo "#!/bin/bash" > $new_file
	echo "$directory/parsing.py -blastxml $directory/repeats_and_vars/fastas/blast_results/${file}_repeats_and_vars.blast_result.xml -fasta_file $directory/repeats_and_vars/fastas/${file}_repeats_and_vars.fa -classified_file $directory/repeats_and_vars/${file}.repeats_and_vars -out $directory/blasted_and_parsed_cortex_calls/${file}_blasted_and_parsed_cortex_calls" >> $new_file
	echo "$directory/anisimov_containers/${file} ${file}.parsing" >> $directory/anisimov_containers/JobList.txt #adding file to JobLIst in required format
done

#Execute anisimov launcher to add execute python script on each sample on an individual core
mpiexec -n ${cores} --bycore -machinefile ${PBS_NODEFILE} /projects/bioinformatics/builds/AnisimovLauncher/scheduler.x $directory/anisimov_containers/JobList.txt /bin/bash > $directory/scheduler.log

rm -r $directory/anisimov_containers
rm -r $directory/Cortex_calls_only_sequences 
