
#!/usr/bin/env python

#Obtain the AA Fasta of the supported genes associated to fusion isoforms of the reference that previously had more than one Uniprot protein hit

#PART 1
#Obtain genes with more that one uniprot hit:
fusion_genes = []

with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/analyze_multiple_uniprot_hits/fusion_gge_more_uniprot_hits_unique.tsv", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		genes = line_list[0].split("_")
		for item in genes:
			fusion_genes.append(item)

#PART 2
#Obtain the supported genes associated to fusion isoforms without duplicates:
id_genes_f_unique=list(set(fusion_genes))

#PART 3
#Reading the fasta file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/protein_fasta/filtered_supported_associated_fusion_genes.fasta", "r") as fasta_in:
	dict_prot_aa = {}
	for line in fasta_in:
		if line.startswith(">") and line.endswith("\n"): #If header,
			gene_id = line.split(".")[0].lstrip(">").rstrip("\n") #Get protein id
			seq = "" #Sequence
			dict_prot_aa[gene_id]=seq
		if not line.startswith(">"): #If sequence,
			line_clean=line.rstrip("\n")
			sequence = dict_prot_aa[gene_id]+str(line_clean) #Append sequence
			dict_prot_aa[gene_id]=sequence #Create dict entry

#PART 4
#Generate the lines for the fasta file
fusion_fasta=[]

for fusion_gene in id_genes_f_unique:
	if fusion_gene in  dict_prot_aa.keys():
		gene_id=">"+str(fusion_gene)
		sequence=dict_prot_aa[fusion_gene]
		fusion_fasta.append(gene_id)
		fusion_fasta.append(sequence)

#PART 5
#Write the final file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_gge_new_busco_sqanti_ncbi_prot_filtered/sqanti_ncbi_input/sup_fusion/blast_human/analyze_fusion/analyze_multiple_uniprot_hits/filtered_supported_associated_fusion_genes_more_uniprot_hits.fasta", "w") as output:
       for line in fusion_fasta:
               output.write(str(line)+"\n")

