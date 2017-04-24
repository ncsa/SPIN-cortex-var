#!/usr/bin/python 

#taking in command line arguments
import argparse
import re

parser=argparse.ArgumentParser(description="arguments for make_fasta.py")
parser.add_argument('-seqs', type=str, required=True, help='full path to cortex calls output file containing only sequences')
parser.add_argument('-calls', type=str, required=True, help='full path to cortex calls classified file containing what what call was specified')
parser.add_argument('-o', type=str, required=True, help='output file')
args=parser.parse_args()
(seq_file, classified_file, out_file)=(args.seqs, args.calls, args.o)

seq_fh=open(seq_file, "r")
class_fh=open(classified_file, "r")
out_fh=open(out_file, "w")


#make a dictionary containing call id as key, and variant type as value
cortex_calls={}
for line in class_fh:
	line=line.strip()
	line=line.split()
	var_id=line[0]
	call_type=line[1]
	cortex_calls[var_id]=call_type
class_fh.close()

#make a fasta file for branch1 and branch2 sequences
i=1
inkeys=0
for line in seq_fh:
	if i%8==3:
		match=re.match(r'>(var_.+_)(branch_1 length.+)', line)
		branch1_query=match.group(1)
		rest=match.group(2)
		if branch1_query in cortex_calls.keys():
			out_fh.write(">"+branch1_query+rest+"\n")
			inkeys=1
	if i%8==4 and inkeys==1:
		line=line.strip()
		out_fh.write(line+"\n")
		inkeys=0
	if i%8==5:
		match=re.match(r'>(var_.+_)(branch_2 length.+)', line)
		branch2_query=match.group(1)
		rest=match.group(2)
		if branch2_query in cortex_calls.keys():
			out_fh.write(">"+branch2_query+rest+"\n")
			inkeys=1
	if i%8==6 and inkeys==1:
		line=line.strip()
                out_fh.write(line+"\n")
		inkeys=0
	i+=1
seq_fh.close()
		
