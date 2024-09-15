#!/usr/bin/env python

#Script to transform hints' file into a GTF file

#PART 1
#Obtain genes and transcript from SQANTI isoforms
gene_id_isoforms={}

with open("/home/crisag/manatee/augustus_busco_sqanti/get_hints_gtf/filtered_hq_isoforms_manatee_sqanti_corrected.gtf.cds.nine_col.gff", "r") as file_in:
	for line in file_in:
		isoform=line.rstrip("\n").split(";")[0].split(" ")[1].strip("\"")
		gene_id=line.rstrip("\n").split(";")[1].split(" ")[2].strip("\"")
		if isoform not in gene_id_isoforms.keys() and gene_id not in gene_id_isoforms.values():
			gene_id_isoforms[isoform]=[gene_id]
		elif isoform in gene_id_isoforms.keys():
			values=gene_id_isoforms[isoform]
			if gene_id in values:
				pass
			else:
				gene_id_isoforms[isoform].append(gene_id)

#PART 2
#Reading the hints file and storing certain files:
hints_gtf = []

with open("/home/crisag/manatee/augustus_busco_sqanti/get_hints_gtf/manatee_gge_final_hints_file_CDS.gff", "r") as file_in:
	for line in file_in:
		line_list = line.split("\t")
		#Obtain isoform
		isoform = line_list[8].split(";")[0].split("=")[1]
		#If it is PB isoform,
		if isoform.startswith("PB"):
			gene_id=str(gene_id_isoforms[isoform]).lstrip("[").rstrip("]").strip("\'")
		#If it is not a PB isoform,
		if not isoform.startswith("PB"):
			gene_id=str(isoform).split(".")[0]

		#Create and append the line
		nine_col="transcript_id"+" "+"\""+str(isoform)+"\""+"; "+"gene_id"+" "+"\""+str(gene_id)+"\""+";"
		line_gtf_list = [line_list[0],line_list[1],line_list[2],line_list[3],line_list[4],line_list[5],line_list[6], line_list[7],nine_col]
		line_gtf = "\t".join(line_gtf_list)
		hints_gtf.append(line_gtf)

#PART 3
#Write final file:
with open("/home/crisag/manatee/augustus_busco_sqanti/get_hints_gtf/hints_augustus_sqanti_gtf.gff", "w") as output:
       for line in hints_gtf:
               output.write(str(line)+"\n")

