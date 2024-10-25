#!/usr/bin/env python

#Script to classify the lrb genes associated to the reference fusion isoforms depending on their level of support

#PART 1
#Creating the non-supported genes' list:
non = [] #List to store non-supported genes
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/analyze_fusion_isoforms/non_supported_manatee_gge_busco_sqanti_isoforms_reduced_filtered.gtf", "r") as file_in:
	for line in file_in:
		non.append(line.strip("\n"))

#PART 2
#Creating the supported genes' list:
sup = [] #List to store the supported genes

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/analyze_fusion_isoforms/supported_manatee_gge_busco_sqanti_isoforms_reduced_filtered.gtf", "r") as file_in:
	for line in file_in:
		sup.append(line.strip("\n"))
#PART 3
#Obtaining the classification of the associated genes of fusion isoforms
lista_archivo = []

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/analyze_fusion_isoforms/fusion_isoforms_ncbi_input_classification_reduced.txt", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		genes = line_list[1].strip("\n").split("_")
		if set(genes) & set(non) and set(genes) & set(sup): #If genes are in both lists,
			linea = str(line_list[0])+"\t"+str(line_list[1].strip("\n"))+"\t"+"mixto"+"\n" #It is annotated as mix
			lista_archivo.append(linea)
		if set(genes) & set(non) and not set(genes) & set(sup): #If genes are only present in the non-supported list,
			linea = str(line_list[0])+"\t"+str(line_list[1].strip("\n"))+"\t"+"non-supported"+"\n"
			lista_archivo.append(linea) #It is annotated as non-supported
		if set(genes) & set(sup) and not set(genes) & set(non): #If genes are only in the supported list,
			linea = str(line_list[0])+"\t"+str(line_list[1].strip("\n"))+"\t"+"supported"+"\n"
			lista_archivo.append(linea) #It is annotated as supported

#PART 4
#Writing final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/analyze_fusion_isoforms/fusions_clasification_genes_ass.tsv", "w") as output:
       for i in lista_archivo:
               output.write(str(i))

