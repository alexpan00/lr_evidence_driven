#!/usr/bin/env python

#Script for formmating the Uniprot's hits of the supported lrb associated genes of the reference fusion isoforms 

#PART 1
#Reading the file and storing the supported associated genes of fusion genes with their Uniprot hit:
archivo = []

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/complete_analysis/gge_sup_genes_fusion_hit_uniprot_multiple_hits_uniprot_filtered.tsv", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t") #Obtenemos una lista con los items de la línea
		#Obtaining the isoform, the associated gene and the uniprot hit
		isoform_ncbi=line_list[0]
		gge_gene = line_list[1]
		uniprot_id = line_list[2].strip("\n")
		#If there are no Uniprot hits' common hits in the associated genes:
		if uniprot_id ==  "[]":
			linea=str(isoform_ncbi)+"\t"+str(gge_gene)+"\t"+str(uniprot_id)+"\t"+"no_common_uniprot_ids"
			archivo.append(linea)
		#If there are common hits,
		if uniprot_id !=  "[]":
			uniprot_id_f= uniprot_id.lstrip("[").rstrip("]")
			linea=str(isoform_ncbi)+"\t"+str(gge_gene)+"\t"+str(uniprot_id_f)+"\t"+"common_uniprot_ids"
			archivo.append(linea)

#PART 2
#Creating the final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/complete_analysis/gge_sup_genes_fusion_hit_uniprot_multiple_hits_uniprot_filtered_formated.tsv", "w") as output:
       for line in archivo:
               output.write(str(line)+"\n")

