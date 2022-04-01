#!/bin/bash
#SBATCH --job-name=hints # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-12:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=hints.log # Standard output and error log

# Script to generate a hints file from a GTF file. Different kinds of sources
# can be specified 


# Check args
if [ -z "$1" ] || [ $1 == '-h' ]
then
    echo "Script to generate hints from gtf file."
    echo "Args:"
    echo -e "\tgtf/gff complete path"
    echo -e "\tUTR (TRUE/FALSE) include UTRS in the hints file"
    echo -e "\tSource (M,PB,...) the type of source used by AUGUSTUS"
    echo -e "\tPriority: used by AUGUSTUS in case of contradiction between hints"
    echo -e "\tTrust the complete exon and introns or used as support (TRUE/FALSE)"
    echo -e "\tPath of the gtf file directory"
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
pri=$4      # Priority
part=$5     # Trust the complete exon/intron
wd=$6       # Working directory
name=$7     # Name for the output
chr=$8      # Do for only one chromosome

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

# Remove gene_id and change transcript id for grp_id
sed -i 's/gene_id[^;]*;//g' tmp2.gff
sed -i 's/transcript_id \"/grp=/g' tmp2.gff

# change the trancript id for the source
cat tmp2.gff | sed "s/$/;pri=$pri;src=$src/g" > $name.hits.gff
rm tmp2.gff

if [ $part == "FALSE" ]
then
    echo "hola"
    sed -i "s/exon/exonpart/g" $name.hits.gff
    sed -i "s/intron/intronpart/g" $name.hits.gff
    sed -i "s/CDS/CDSpart/g" $name.hits.gff
fi


