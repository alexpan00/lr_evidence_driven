#!/usr/bin/env python

#Script for obtainning the supported lrb genes that have multiple Uniprot's hits

#PART 1
#Reading the file and store in the list the supported isoforms:
archivo = []

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/analyze_multiple_uniprot_hits/blast/multiple_uniprot_hits_proteins_supported_genes_ass_fusion_blastp_human_ncbi_input_table_reduced_uniq.txt", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		#Obtaining the isoform, protein id from Uniprot
		isoform = line_list[0]
		prot_id = line_list[1].split("|")[1]
		line_n=str(isoform)+"\t"+str(prot_id)
		archivo.append(line_n) #Append both

#PART 2
#Writing the final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/analyze_multiple_uniprot_hits/blast/multiple_uniprot_hits_proteins_supported_genes_ass_fusion_blastp_human_ncbi_input_table_reduced_uniq_complete.txt", "w") as output:
       for line in archivo:
               output.write(str(line)+"\n")

