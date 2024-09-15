#!/usr/bin/env python

import numpy as np

#Script to obtain the matching Uniprot hit of the supported lrb gene associated to fusions' isoforms of the reference annotation

#PART 1
#Reading file and storing the fusion associated genes with their proteins' hits:
dict_gge_gene_uniprot = {}

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/analyze_multiple_uniprot_hits/blast/multiple_uniprot_hits_proteins_supported_genes_ass_fusion_blastp_human_ncbi_input_table_reduced_uniq_complete.txt", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		#Obtain gene and  Uniprot ID
		gge_gene = line_list[0]
		uniprot_id = line_list[1].strip("\n")
		if gge_gene not in dict_gge_gene_uniprot.keys():
			dict_gge_gene_uniprot[gge_gene]=[uniprot_id]
		elif gge_gene in dict_gge_gene_uniprot.keys():
			dict_gge_gene_uniprot[gge_gene].append(uniprot_id)

#PART 2
#Reading the SQANTI3 classification file containing the supported genes associated to fusion isoforms
dict_id_ncbi={} #Dict to store the genes and their Uniprot's hits
dict_id_ncbi_gge_gene = {} #Dict to store the isoform and their associated gene

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/analyze_multiple_uniprot_hits/get_fasta/gge_sup_genes_fusion_hit_uniprot_no_no_hit_class_final_more_uniprot_hits.tsv", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		#Obtain isoform ID and associated genes
		isoform = line_list[0]
		complete_gene = line_list[1]
		dict_id_ncbi_gge_gene[isoform]=complete_gene
		gene_id_list = line_list[1].split("_")
		for gene_id in gene_id_list:
			#If gene in the dict of the transcripts and Uniprot hits:
			if gene_id in dict_gge_gene_uniprot.keys():
				uniprot_id_r = dict_gge_gene_uniprot[gene_id] #Obtain the Uniprot proteins' ids
				if isoform not in dict_id_ncbi.keys(): #If the isoform is not in the dict,
					dict_id_ncbi[isoform]=[uniprot_id_r] #The entry is made
				elif isoform in dict_id_ncbi.keys(): #If the isoform is in the dict
					dict_id_ncbi[isoform].append(uniprot_id_r) #The Uniprot's IDs are appended

#PART 3
#Obtain common Uniprot common hits:
dict_final = {}

for isoform_id, uniprot_ids in dict_id_ncbi.items():
	uniprot_common = list(set.intersection(*map(set,uniprot_ids)))
	dict_final[isoform_id]=uniprot_common


#PART 4
#Parsing final file
archivo = []

for ncbi_isoform, uniprot_ids in dict_id_ncbi.items():
	gene_list = dict_id_ncbi_gge_gene[ncbi_isoform]
	uniprot_ids_f=str(uniprot_ids)
	common_id=dict_final[ncbi_isoform]
	linea=str(ncbi_isoform)+"\t"+str(gene_list)+"\t"+str(uniprot_ids_f)+"\t"+str(common_id)
	archivo.append(linea)

#PART 5
#Writing the final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/analyze_multiple_uniprot_hits/analyze_classification/gge_sup_genes_fusion_hit_uniprot_multiple_hits_uniprot.tsv", "w") as output:
       for line in archivo:
               output.write(str(line)+"\n")

