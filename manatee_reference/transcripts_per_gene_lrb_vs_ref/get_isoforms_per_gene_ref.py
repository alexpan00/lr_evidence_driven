#!/usr/bin/env python

import pandas as pd

#Script to obtain the number of isoforms per gene in the reference annotation

#PART 1:
# Read header's file:
datos = pd.read_csv("/home/crisag/manatee_reference/get_gff_final/cabecera.txt", sep="\t", header=None, dtype=object)
datos.columns = ['transcript_id', 'gene_id']

#Modify columns:

#a) Modify transcript id string:
datos["transcript_id"] = datos["transcript_id"].str.lstrip(">")

#b) Keeping gene_id:
datos["gene_id"] = datos["gene_id"].str.split(":").str[1].str.rstrip("]")

#c) Obtain number of isoforms per gene:
grouped = datos.gene_id.value_counts().reset_index(name='number_isoforms')

#PART 2
#Writing final file:
grouped.to_csv("/home/crisag/manatee_reference/get_isoforms_per_gene/isoforms_per_gene_ncbi.tsv", sep="\t")

