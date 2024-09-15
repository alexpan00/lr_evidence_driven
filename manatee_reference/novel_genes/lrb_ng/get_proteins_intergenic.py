#!/usr/bin/env python

import pandas as pd

#Script to obtain the AA FASTA of intergenic isoforms

#PART 1
#Reading aa FASTA file:
with open("/home/crisag/manatee/augustus_busco_sqanti/augustus_isoform_mode/output_augustus/manatee_gge_busco_sqanti_isoforms.aa", "r") as fasta_in:
	dict = {} #Dictionary for storing the transcript ID as a key and the sequence as a value
	for line in fasta_in:
		if line.startswith(">") and line.endswith("\n"): #If header:
			prot_id = line.lstrip(">").rstrip("\n") #Obtain the protein ID (transcript_id)
			seq = "" #Sequence
		elif line.endswith("\n"): #If sequence:
			line_clean=line.rstrip("\n")
			seq = seq+line_clean #Obtain sequence
		dict[prot_id]=seq #Create protein entry

#PART 2
#Reading the file with the ID of the intergenic isoforms and obtain the IDs of the proteins that are intergenic
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_gge_input/blast/intergenic_isoforms/get_proteins/intergenic_isoforms_id", "r") as file_in:
	protein_id_i = []
	for line in file_in:
		isoform = line.rstrip("\n")
		protein_id_i.append(isoform) #The isoform is added to the list

#PART 3
#Filtering of the fasta file by the IDs of proteins that are classified as intergenic:
fasta_list=[]

for id in protein_id_i:
	if id in dict.keys(): #If the ID of the list is in the dictionary keys,
		seq=dict[id] #The sequence is obtained
		id_f= ">"+id #Creating fasta header
		#Append both the header and sequence
		fasta_list.append(id_f)
		fasta_list.append(seq)

#PART 4
#Write final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_gge_input/blast/intergenic_isoforms/get_proteins/proteins_gge_intergenic.aa", "w") as output:
	for i in fasta_list:
		output.write(i + "\n")
