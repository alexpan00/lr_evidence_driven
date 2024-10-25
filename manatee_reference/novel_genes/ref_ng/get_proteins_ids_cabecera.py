#!/usr/bin/env python

#Script to get the reference annotation protein-coding isoforms

#PART 1
#Reading the file containing the fasta headers:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti/sqanti_ncbi_input/blast_filtered/get_prot_ids_cabecera/cabecera_fasta.txt", "r") as file_in:
	lines_final_file = [] #List to store the isoform and their associated protein
	for line in file_in:
		line_list = line.split(" ") #Line splitting
		isoform = line_list[0].lstrip(">") #Obtaining isoform id
		for i in line_list:
			if i.startswith('[protein_id='): #If header has the protein_id field
				prot_id=str(i.split("=")[1].rstrip("]")) #Obtain isoform ID
				lines_final_file.append("\t".join([isoform,prot_id])) #Add that both isoform and protein id

#PART 2
#Create the file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti/sqanti_ncbi_input/blast_filtered/get_prot_ids_cabecera/file_isoform_with_prot_id.txt", "w") as output:
	for i in lines_final_file:
		output.write(str(i) + "\n")


