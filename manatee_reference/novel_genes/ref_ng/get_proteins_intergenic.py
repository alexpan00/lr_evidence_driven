#!/usr/bin/env python

import pandas as pd

#Script to obtain the AA FASTA of intergenic isoforms

#PART 1:
#Read file containing the isoform and associated protein
isoform_prot_id = pd.read_csv("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti/sqanti_ncbi_input/blast_filtered/get_prot_ids_cabecera/file_isoform_with_prot_id.txt", sep="\t", header=None)
isoform_prot_id.columns = ['transcript_id', 'prot_id']

#Creating the dict:
dict_isoform_prot_id = isoform_prot_id.set_index("transcript_id")["prot_id"].to_dict()

#PART 2
#Reading the reference aa FASTA:
with open("/home/crisag/manatee_reference/ncbi_data_set/GCF_000243295.1/protein.faa", "r") as fasta_in:
	dict = {} #Dictionary for storing the transcript ID as a key and the sequence as a value
	for line in fasta_in:
		if line.startswith(">") and line.endswith("\n"): #If header,
			prot_id = line.lstrip(">").rstrip("\n").split(" ")[0] #Obtain the protein ID (transcript_id)
			seq = "" #Sequence
		elif line.endswith("\n"): #If sequence:
			line_clean=line.rstrip("\n")
			seq = seq+line_clean #Appending the sequence
		dict[prot_id]=seq #Create protein entry

#PART 3
#Reading the file with the ID of the intergenic isoforms and obtain the IDs of the proteins that are intergenic.
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/blast/intergenic_isoforms/get_proteins/intergenic_isoforms_id", "r") as file_in:
	protein_id_in = []
	for line in file_in:
		isoform = line.rstrip("\n")
		if isoform in dict_isoform_prot_id.keys(): #If isoform has protein id:
			prot_id = dict_isoform_prot_id[isoform]
			protein_id_in.append(prot_id) #Append the protein ID

#PART 4
#Filtering of the fasta file by the IDs of proteins that are classified as intergenic
fasta_list=[]

for id in protein_id_in:
	if id in dict.keys(): #If the ID of the list is in the dictionary keys,
		seq=dict[id] #Obtaining the protein sequence
		id_f= ">"+id #Creating fasta header
		#Append both the header and sequence
		fasta_list.append(id_f)
		fasta_list.append(seq)

#PART 5
#Writing final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/blast/intergenic_isoforms/get_proteins/proteins_ncbi_intergenic.aa", "w") as output:
	for i in fasta_list:
		output.write(i + "\n")
