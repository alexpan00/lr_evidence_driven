#!/usr/bin/env python

import pandas as pd

#Script to put the GTF gene_id field correctly

#PART 1:
#Read FASTA's headers:
datos = pd.read_csv("/home/crisag/manatee_reference/get_gff_final/cabecera.txt", sep="\t", header=None, dtype=object)
datos.columns = ['transcript_id', 'gene_id']

#Modify columns:

#a) Keep protein id without '>':
datos["transcript_id"] = datos["transcript_id"].str[1:]

#b) Keep only the gene ID (numbers):
datos["gene_id"] = datos["gene_id"].str[16:-1]

#Create gene dict:
dict_gen_transcript = datos.set_index("transcript_id")["gene_id"].to_dict()

def get_dict(my_dict):
	new_dict ={}
	for key, value in my_dict.items():
		k=str(key)
		v=str(value)
		new_dict[k]=v
	return new_dict

new_dict=get_dict(dict_gen_transcript)

#PART 2
#Read file:
with open("/home/crisag/manatee_reference/sqanti3/sqanti3_new_ref/gtf_mod/ref_manatee_mapped_primary_aln_2.gff", "r") as file_in:
	lines = []
	for line in file_in:
		line_list = line.split("\t") #Obtain list with the items of each line
		transcript = line_list[8].split(" ")[1] #Obtain transcript ID
		if transcript.endswith(";"): #If ID ends with ";", this is removed
			transcript1=transcript.strip(";") #Obtain ID
			transcript1_2= transcript1[1:-1] #Without ""
			gen1 = new_dict.get(transcript1_2)
			frase_lista_9 = ["transcript_id",'"',transcript1_2,'"', "; " ,"gene_id", '"',gen1, '"']
			frase_9 = " ".join(frase_lista_9)
			frase_9_f = frase_9.replace('" ', '"').replace(' "', '"').replace('id"', 'id "')
			frase_completa = [line_list[0],line_list[1],line_list[2],line_list[3],line_list[4],line_list[5],line_list[6], line_list[7], frase_9_f]
			frase_completa_f = "\t".join(frase_completa)
			lines.append(frase_completa_f)
		elif transcript.endswith(";\n"): #If ID ends with ";\t", this is removed
			transcript2=transcript.strip(";\n") #Obtain ID
			transcript2_2=transcript2[1:-1] #Without ""
			gen2 = new_dict.get(transcript2_2)
			frase_lista_9 = ["transcript_id",'"',transcript2_2,'"', "; " ,"gene_id", '"',gen2, '"']
			frase_9 = " ".join(frase_lista_9)
			frase_9_f = frase_9.replace('" ', '"').replace(' "', '"').replace('id"', 'id "')
			frase_completa = [line_list[0],line_list[1],line_list[2],line_list[3],line_list[4],line_list[5],line_list[6], line_list[7], frase_9_f]
			frase_completa_f = "\t".join(frase_completa)
			lines.append(frase_completa_f)

#PART 3
#Write final file:
with open("/home/crisag/manatee_reference/get_gff_final/gtf_ncbi_manatee_final.gtf", "w") as output:
	for i in lines:
		output.write(i + '\n')

