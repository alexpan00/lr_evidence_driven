#!/usr/bin/env python

#Script to obtain the number of Uniprot hit's of the lrb genes associated to the reference fusion isoforms

#PART 1
#Reading the file and storing the fusion Uniprot hits:
archivo = []

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/get_classification/gge_sup_genes_fusion_hit_uniprot_no_no_hit.tsv", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		#Obtaining isoform, gene and uniprot ids
		isoform = line_list[0]
		gene_list = line_list[1]
		uniprot_id = line_list[2].rstrip("\n").split(",")
		#Check the number of hits of each gene:
		if len(uniprot_id) > 1:
			line_f=str(isoform)+"\t"+str(gene_list)+"\t"+str(",".join(uniprot_id))+"\t"+"more_than_1_uniprot_id"
		if len(uniprot_id) == 1:
			line_f=str(isoform)+"\t"+str(gene_list)+"\t"+str(uniprot_id[0])+"\t"+"1_uniprot_id"
		archivo.append(line_f)


#PART 2
#Writing the final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/analyze_classification/gge_sup_genes_fusion_hit_uniprot_no_no_hit_class_final.tsv", "w") as output:
       for line in archivo:
               output.write(str(line)+"\n")
