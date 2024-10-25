#!/usr/bin/env python

#Script to get if the fusion isoforms' lrb associated genes had an Uniprot's hit

#PART 1
#Reading the file and storing the supported associated genes of fusion isoforms has an Uniprot hit:
dict_gge_gene_uniprot = {}

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/out_blast/proteins_supported_genes_ass_fusion_blastp_human_ncbi_input_table_reduced_no_repeated_ids.txt", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		#Obtain gene and protein ID
		gge_gene = line_list[0].split(".")[0]
		uniprot_id = line_list[1].strip("\n")
		dict_gge_gene_uniprot[gge_gene]=uniprot_id #Create dict entry

#PART 2
#Reading SQANTI3 classification file with the fusion's supported associated genes
dict_id_ncbi={}
dict_id_ncbi_gge_gene = {}

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/protein_fasta/fusions_clasification_genes_ass_no_non_supported_mixto.tsv", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		#Obtaining the isoform ID and gene ids
		isoform = line_list[0]
		complete_gene = line_list[1]
		#Create dict entry:
		dict_id_ncbi_gge_gene[isoform]=complete_gene
		#Analyze genes:
		gene_id_list = line_list[1].split("_")
		for gene_id in gene_id_list:
			#If gene is present in dict of transcript with Uniprot's hits
			if gene_id in dict_gge_gene_uniprot.keys():
				uniprot_id_r = dict_gge_gene_uniprot[gene_id] #Obtaining protein ID
				#If the isoform is not in the dict,
				if isoform not in dict_id_ncbi.keys():
					dict_id_ncbi[isoform]=[uniprot_id_r] #The entry is created
				#If the isoform is in the dict, but the protein id is not
				elif isoform in dict_id_ncbi.keys() and uniprot_id_r not in dict_id_ncbi[isoform]: #Si el id de Uniprot no está entre los valores de esa isoforma
					dict_id_ncbi[isoform].append(uniprot_id_r) #The protein ID is added
				#If the protein ID is associated to the isoform,
				elif isoform in dict_id_ncbi.keys() and uniprot_id_r in dict_id_ncbi[isoform]:
					pass
			#If the gene is not in the dict of transcript with Uniprot's hits
			elif gene_id not in dict_gge_gene_uniprot.keys():
				#If the isoform is not in the dict,
				if isoform not in dict_id_ncbi.keys():
					dict_id_ncbi[isoform]=["no_hit"] #The dict entry is created with 'no_hit' as value
				#If the isoform is already in the dict
				elif isoform in dict_id_ncbi.keys():
					dict_id_ncbi[isoform].append("no_hit") #'no_hit' is added in the dict entry

#PART 3
#Creating the file:
archivo = []

for ncbi_isoform, uniprot_ids in dict_id_ncbi.items():
	gene_list = dict_id_ncbi_gge_gene[ncbi_isoform]
	uniprot_ids_f=str(uniprot_ids).lstrip("[").rstrip("]")
	linea=str(ncbi_isoform)+"\t"+str(gene_list)+"\t"+str(uniprot_ids_f)
	archivo.append(linea)

#PART 4
#Writing the final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/gge_sup_genes_fusion_hit_uniprot.tsv", "w") as output:
       for line in archivo:
               output.write(str(line)+"\n")


