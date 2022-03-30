#!/bin/bash
# Check args
if [ -z "$1" ] || [ $1 == '-h' ]
then
    echo "Script to generate hints from gtf file."
    echo "Args:"
    echo -e "\tgtf/gff"
    echo -e "\tUTR (TRUE/FALSE) include UTRS in the hints file"
    echo -e "\tSource (M,PB,...) the type of source used by AUGUSTUS"
    echo -e "\tPath of the gtf file"
    echo -e "\tName for the outputs"
    echo -e "\tChromosome (optional) Do only for one chromosome ej: chr19"
    exit 0
fi

pwd;date
# module load conda
source activate busco

# PATH
utilities="/home/apadepe/utilities/"

# INPUTS
gff=$1      # gtf to be converted to hits
utr=$2      # include or exclude utr
src=$3      # Source of the information (M,PB)
wd=$4       # Working directory
name=$5     # Name for the output
chr=$6      # Do for only one chromosome

cd $wd
# Filter one chromosome from the original gtf
if [ -n "$chr" ]
then
    grep $chr $gff > tmp.gff
    gff="tmp.gff"
fi

# add explicit introns
# If the model was trained to use UTR keep exons and CDS
if [ "$utr"  == "TRUE" ]
then
    grep -P "\t(CDS|exon)\t" $gff | gtf2gff.pl --printIntron --out=tmp.gff
    grep -P "\t(CDS|intron|exon)\t" tmp.gff > tmp2.gff
# If the model was't trained to use UTR keep only the CDS
else
    grep -P "\t(CDS)\t" $gff | gtf2gff.pl --printIntron --out=tmp.gff
    grep -P "\t(CDS|intron)\t" tmp.gff > tmp2.gff
fi
rm tmp.gff

# change gene_id for grp_id
sed -i 's/gene_id \"/grp=/g' tmp2.gff

# change the trancript id for the source
# TO DO: add othe possible sources
cut -f1 -d'"' tmp2.gff | sed 's/$/;pri=1;src=M/g' > $name.hits.gff
rm tmp2.gff


