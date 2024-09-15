#!/usr/bin/env python

#Script to obtain a supported GTF with the genes associated to fusion isoforms of the reference annotation

#PART 1
#Obtain supported genes associated with fusion isoforms:
fusion_genes = []

with open("~/manatee_reference/sqanti3/sqanti3_hints_vs_augustus_supported_fusions/get_files/get_augustus_gtf/fusions_clasification_genes_ass_no_non_supported_mixto.tsv", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		genes = line_list[1].strip("\n").split("_")
		for item in genes:
			fusion_genes.append(item)

#PART 2
#Obtain the list of supported genes supported associated with fusion isoforms without duplicates:
id_genes_f_unique=list(set(fusion_genes)) #Associated genes


#PART 3
#Reading supported GTF file and storing the lines of supported genes contained in the file in a list:
supported_gtf_fusion = [] #List for storing the lines

with open("~/manatee_reference/sqanti3/sqanti3_hints_vs_augustus_supported_fusions/get_files/get_augustus_gtf/supported_manatee_gge_busco_sqanti_isoforms_reduced_CDS.gtf", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t") #Obtain a list with items of the line
		nine_col = line_list[8].strip("\n") #Obtain the isoform
		gene_id = nine_col.split(" ")[3].rstrip(";").strip("\"") #Obtain the gene
		if gene_id in id_genes_f_unique:
			supported_gtf_fusion.append(line)

#PART 4
#Generate the final GTF file with the lines containing the supported genes associated to fusion isoforms:
with open("~/manatee_reference/sqanti3/sqanti3_hints_vs_augustus_supported_fusions/get_files/get_augustus_gtf/filtered_associated_fusions_supported_manatee_gge_busco_sqanti_isoforms_reduced_CDS.gtf", "w") as output:
       for line in supported_gtf_fusion:
               output.write(str(line))

