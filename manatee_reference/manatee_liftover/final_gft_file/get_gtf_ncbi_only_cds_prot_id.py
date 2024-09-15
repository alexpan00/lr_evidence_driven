#!/usr/bin/env python

#Script to obtain only the reference protein-coding isoforms

#PART 1
#Read the file and select only the isoforms that have associated proteins:
isoforma_prot_id = [] #List where the lines with the isoforms and their associated protein will be stored
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/gtfs_finales/cabecera_fasta.txt", "r") as file_in:
	for line in file_in:
		line_list = line.split(" ") #Obtain the parts of the list
		for i in line_list: #Looping through items in the list
			if i.startswith('[protein_id='): #If the isoform is protein-coding, the "protein_id" field will appear at the fasta header
				isoform = line_list[0].lstrip(">") #Obtaining the isoform ID
				isoforma_prot_id.append(isoform) #Adding that isoform ID

#PART 2
#Reading the GTF of the NCBI that will be filtered:
file_lines = [] #List where lines containing protein-coding isoforms will be stored
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/gtfs_finales/gtf_ncbi_manatee_final.gtf", "r") as file_in:
	for line in file_in:
		isoform_id = line.split("\t")[8].split(" ")[1].lstrip("\"").rstrip("\";") #Obtain transcript ID
		if isoform_id in isoforma_prot_id: #If this isoform ID is in the protein-coding isoform IDs
			file_lines.append(line) #The line of the GTF is added

#PART 3
#Writing the final GTF containing only protein-coding isoforms:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/gtfs_finales/gtf_ncbi_protein_coding_isoforms.gtf", "w") as output:
	for i in file_lines: #For each element of the list,
		output.write(str(i)) #The line is written


