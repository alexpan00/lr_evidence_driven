#!/usr/bin/env python

#Obtain the AA Fasta of the supported genes associated to fusion isoforms of the reference

#PART 1
#Reading the file and storing the supported isoforms:
sup = [] #List to store supported genes
dict_s_gen_isof = {} #Dictionary to store genes and their isoforms

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/supported_manatee_gge_busco_sqanti_isoforms_reduced_filtered.gtf", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		#Obtain the isoform and gene:
		isoform = line_list[8].strip("\n")
		gene_id = isoform.split(".")[0]
		if gene_id not in dict_s_gen_isof.keys(): #If gene not in dict,
			dict_s_gen_isof[gene_id]=[isoform] #Create dict entry
			sup.append(gene_id) #Add gene to list
		elif gene_id in dict_s_gen_isof.keys(): #If gene in dict keys',
			dict_s_gen_isof[gene_id].append(isoform) #The isoform is added

#PART 2
#Obtain supported genes associated to fusion isoforms:
fusion_genes = []

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/fusions_clasification_genes_ass_no_non_supported_mixto.tsv", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		genes = line_list[1].strip("\n").split("_")
		for item in genes:
			fusion_genes.append(item)

#PART 3
#Obtain an unique list of supported genes associated to fusion isoforms:
id_genes_f_unique=list(set(fusion_genes))

#PART 4
#Reading the AA FASTA file:
with open("/home/crisag/manatee/augustus_busco_sqanti/augustus_isoform_mode/output_augustus/manatee_gge_busco_sqanti_isoforms.aa", "r") as fasta_in:
	dict_prot_aa = {} #Dictionary in which we store the transcript ID as the key and the sequence as the value
	for line in fasta_in:
		if line.startswith(">") and line.endswith("\n"): #If header,
			prot_id = line.lstrip(">").rstrip("\n") #Obtain protein id
			seq = "" #Sequence
			dict_prot_aa[prot_id]=seq
		if not line.startswith(">"): #If not header,
			line_clean=line.rstrip("\n")
			sequence = dict_prot_aa[prot_id]+str(line_clean)
			dict_prot_aa[prot_id]=sequence #Create dict entry

#PART 5
#Obtain fusions' associated supported genes and check if they have more than one isoform:
dict={}

for gene in id_genes_f_unique:
	if gene in dict_s_gen_isof.keys():
		isoforms=dict_s_gen_isof[gene]
		if len(isoforms) > 1:
			dict[gene]="more than 1 isoform"

print( "There are", len(dict.keys()), "supported genes with more than one isoform")

#PART 6
#Get the protein sequence of the supported genes associated to fusion isoforms:
fusion_fasta=[]

for fusion_gene in id_genes_f_unique:
	if fusion_gene in dict_s_gen_isof.keys():
		isoforms=dict_s_gen_isof[fusion_gene]
		if isoforms[0] in dict_prot_aa.keys():
			sequence=dict_prot_aa[isoforms[0]]
			prot_id=">"+str(isoforms[0])
			fusion_fasta.append(prot_id)
			fusion_fasta.append(sequence)

#PART 7
#Write final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/filtered_supported_associated_fusion_genes.fasta", "w") as output:
       for line in fusion_fasta:
               output.write(str(line)+"\n")

