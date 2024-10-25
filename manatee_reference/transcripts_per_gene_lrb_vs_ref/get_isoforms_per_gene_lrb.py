#!/usr/bin/env python

#Script to obtain the number of isoforms per gene in the lrb annotation

#PART 1
#Reading file:
dict={} #Dict to store the genes and number of isoforms

with open("/home/crisag/manatee/augustus_busco_sqanti/augustus_isoform_mode/get_isoforms_per_gene/transcripts_manatee_gge_busco_sqanti_isoforms_reduced_filtered.txt", "r") as file_in:
	for line in file_in:
		gene=line.split(".")[0]
		transcript=line.split(".")[1].strip("\n")
		#If gene is present in dict,
		if gene in dict.keys():
			num=dict[gene]
			dict[gene]=num+1 #Adding one to counter
		#Id gene is not in dict,
		if gene not in dict.keys():
			dict[gene]=1 #Start isoform's counter

#PART 2
#Parsing the file:
lines=[]

for gen, num in dict.items():
	line=str(gen)+"\t"+str(num)
	lines.append(line)

#PART 3
#Writing the file:
with open("/home/crisag/manatee/augustus_busco_sqanti/augustus_isoform_mode/get_isoforms_per_gene/isoforms_per_gene_gge.tsv", "w") as output:
	for i in lines:
		output.write(i + '\n')

