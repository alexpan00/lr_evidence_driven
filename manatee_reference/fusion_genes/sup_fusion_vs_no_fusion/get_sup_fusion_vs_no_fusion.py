#!/usr/bin/env python

#Script to extract the fusion genes and genes that are not present in fusion isoforms

#PART 1
#Reading the file and storing supported genes:
sup = []

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/analyze_fusion_isoforms/supported_manatee_gge_busco_sqanti_isoforms_reduced_filtered.gtf", "r") as file_in:
	for line in file_in:
		sup.append(line.strip("\n"))
#PART 2
#Obtain the associated supported genes of fusion isoforms
lista_archivo_f =[] #List for the file
id_genes_f=[] #List for the fusions' associated genes

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/analyze_fusion_isoforms/fusion_isoforms_ncbi_input_classification_reduced.txt", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		genes = line_list[1].strip("\n").split("_")
		for item in genes:
			if item in sup:
				linea=str(item)+"\t"+"fusion"+"\n"
				lista_archivo_f.append(linea)
				id_genes_f.append(item)

#PART 3
#Obtain a list of genes without duplicates:
f_list=list(set(lista_archivo_f))
id_genes_f_unique=list(set(id_genes_f))

#PART 4
#Check that fusion genes are not present in other types of isoforms:
lista_archivo_no_f=[]

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion_vs_no_fusion/manatee_ncbi_prot_classification_reduced_nh_no_AS_intergenic_fusion.txt", "r") as file_in:
	for line in file_in:
		type=str(line.split("\t")[1])
		gene=str(line.split("\t")[2])
		#If gene is not in the fusion isoforms' list but it is a supported gene
		if gene not in id_genes_f_unique and gene in sup:
			linea=str(gene)+"\t"+"no-fusion"+"\n"
			lista_archivo_no_f.append(linea)
		#If the gene is supported and it's part of a fusion isoform,
		if gene in id_genes_f_unique and gene in sup:
			linea=str(gene)+"\t"+"no-fusion-gen-fusion"+"\n"
			lista_archivo_no_f.append(linea)
#PART 5
#Remove duplicates:
n_f_list=list(set(lista_archivo_no_f))

#PART 6
#Generate the final list for the file's lines:
mylist=f_list+n_f_list

#PART 7
#Writing the final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion_vs_no_fusion/sup_gen_fusion_iso_vs_no_fusion_supported_real.tsv", "w") as output:
       for i in mylist:
               output.write(str(i))

