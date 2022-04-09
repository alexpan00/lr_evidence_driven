#!/bin/bash
# Simple bash script to read the AUGUSTUS ouput and generate a summary of 
# the stats
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Script to get stats from the AUGUSTUS outputs"
    echo "Expected inputs:"
    echo -e "\tpath to outputs directory"
    exit 0
fi
cd $1
# Add a header
echo -e "N_genes"'\t'"nt_sn"'\t'"nt_sp"'\t'"exon_sn"'\t'"exon_sp"'\t'"gene_sn"'\t'"gene_sp"'\t'"time" > summary.tsv
for file in *.out
do
    N_genes=$(echo $file | cut -f1 -d"." | cut -f2 -d"_")
    nt=$(grep "nucleotide level" $file)
    nt_sn=$(echo $nt | cut -f2 -d"|" | cut -f2 -d" ")
    nt_sp=$(echo $nt | cut -f3 -d"|" | cut -f2 -d" ")
    exon=$(grep "exon level" $file)
    exon_sn=$(echo $exon | cut -f7 -d"|" | cut -f2 -d" ")
    exon_sp=$(echo $exon | cut -f8 -d"|" | cut -f2 -d" ")
    gene=$(grep "gene level" $file)
    gene_sn=$(echo $gene | cut -f7 -d"|" | cut -f2 -d" ")
    gene_sp=$(echo $gene | cut -f8 -d"|" | cut -f2 -d" ")
    tiempo=$(grep "total time" $file | cut -f4 -d" ")
    echo -e "$N_genes"'\t'"$nt_sn"'\t'"$nt_sp"'\t'"$exon_sn"'\t'"$exon_sp"'\t'"$gene_sn"'\t'"$gene_sp"'\t'"$tiempo" >> summary.tsv
done
