#!/usr/local/apps/bioapps/python/Python-2.7.13/bin/python2.7

import argparse
import re
from Bio.Blast import NCBIXML
from Bio.SeqUtils import GC
import sequtils 

parser=argparse.ArgumentParser(description="parse blast out, arguments include input and output file")
parser.add_argument('-blastxml', type=str, required=True, help='full path the blast xml output file')
parser.add_argument('-fasta_file', type=str, required=True, help='full path to the fasta file that was blasted')
parser.add_argument('-classified_file', type=str, required=True, help='full path to classifed calls file')
parser.add_argument('-out', type=str, required=True, help='output file')


args=parser.parse_args()
(infile, fasta, classified, outfile)=(args.blastxml, args.fasta_file, args.classified_file, args.out)

fasta_fh=open(fasta, "r")

#make dictionary containing key as cortex call, and value as the "calltype_qualityscore" to add into the output file of this script
class_fh=open(classified, "r")
qscore_var_type={}
for line in class_fh:
	line=line.strip()
	line=line.split()
	var=line[0]
	qscore_and_var=line[1]+"_"+line[2]
	qscore_var_type[var]=qscore_and_var
class_fh.close()


#make a dictionary of the branch1 and branch2 sequences so that the sequenes can be used fro GC content and entropy calcultion, one line per branch
seq_dict={}
i=1
for line in fasta_fh:
	line=line.strip()
	if i%2==1: #ID line
		match=re.match(r'>(var_\d+_branch_\d).+', line)
		call=match.group(1)
	if i%2==0: #sequence line
		seq_dict[call]=line
	i+=1
fasta_fh.close() 	



result_handle=open(infile)
out_fh=open(outfile, "w")
#out_fh.write("Hello")

blast_records=NCBIXML.parse(result_handle)

i=1
out_fh.write("branch_name\tcall_type\tcortex_quality_score\tbranch_len\tbranch1-branch2_len_differnce\ttop_hsp\tnum_hsps\tsequence_entropy\tsequence_GC_content\n")
#parse file with biopython for
for blast_record in blast_records:
	top_record_hit=0
	qry=blast_record.query
	match=re.match(r'(var_\d+_)(branch_\d).+', qry)
	call_no_branch=match.group(1)
	call=match.group(1)+match.group(2)
	seq=seq_dict[call]
	seq_len=len(seq)
	GC_content=GC(seq)
	entropy=sequtils.entropy(seq)
	print call
	num_hsps=0	#An alignment is a hit on any soy chromosomes, the hsps are the number of hits within the chromosome
	if blast_record.alignments==[]:
		top_hsp="No_HSPs"
	else:
		for alignment in blast_record.alignments:
			#store the top hit for each blast_record as such: chr_sbjtstart
			align=str(alignment)
			match1=re.match(r'gnl\|BL_ORD_ID\|\d*\s(\d*)\n.+', align) #biopython wont give you the alignment sbjct in an easily readable way...im doing it manually
			chromo=match1.group(1)
			hsps_per_align=len(alignment.hsps) 
			num_hsps+=hsps_per_align 
			for hsp in alignment.hsps:
				if top_record_hit==0: #to ensure only the highest scoring hit for the blast hit will be recorded as top hit
					coord=hsp.sbjct_start
					top_hsp=str(chromo)+"_"+str(coord)		
					top_record_hit=1
	#store branch1 data in temporary variable so branch1 and branch2 data can be writted to the same line in output file
	if i%2==1: #branch1
		b1seq_len=seq_len #store branch1 sequence length in variable to calculate difference for branch 2 next
		match=re.match(r'(\D+)_(.+)', qscore_var_type[call_no_branch])
		var_type=match.group(1)
		qscore=match.group(2)
		out_fh.write(call+"\t"+var_type+"\t"+qscore+"\t"+str(seq_len)+"\t"+"--"+"\t"+top_hsp+"\t"+str(num_hsps)+"\t"+str(entropy)+"\t"+str(GC_content)+"\n")
			
	if i%2==0: #branch2
		match=re.match(r'(\D+)_(.+)', qscore_var_type[call_no_branch])
		var_type=match.group(1)
		qscore=match.group(2)
		seq_dif=b1seq_len-seq_len
		out_fh.write(call+"\t"+var_type+"\t"+qscore+"\t"+str(seq_len)+"\t"+str(seq_dif)+"\t"+top_hsp+"\t"+str(num_hsps)+"\t"+str(entropy)+"\t"+str(GC_content)+"\n")	
			
	i+=1	

	
