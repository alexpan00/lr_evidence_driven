#!/bin/bash
#SBATCH --job-name=create_hints_chr19 # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=10G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=gtf2hints_chr19_%j.log # Standard output and error log

# Script to generate a hints file from a GTF file. Different kinds of sources
# can be specified
# check if script is started via SLURM or bash
# if with SLURM: there variable '$SLURM_JOB_ID' will exist
# `if [ -n $SLURM_JOB_ID ]` checks if $SLURM_JOB_ID is not an empty string
if [ -n "$SLURM_JOB_ID" ];  then
    # check the original location through scontrol and $SLURM_JOB_ID
    SCRIPT_PATH=$(scontrol show job ${SLURM_JOB_ID} | grep Command | cut -f2 -d"=" | cut -f1 -d" ")
else
    # otherwise: started with bash. Get the real location.
    SCRIPT_PATH=$(realpath -s $0)
fi
utilities=$(dirname $(dirname $SCRIPT_PATH))

# Check args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
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
    echo -e "\tMode: type of data that will be converted to hints."
    echo -e "\tCan be read, transcript or gene"
    exit 0
fi

pwd;date


# INPUTS
gff=$1      # gtf to be converted to hits
utr=$2      # include or exclude utr
src=$3      # Source of the information (M,PB)
pri=$4      # Priority
part=$5     # Trust the complete exon/intron
wd=$6       # Working directory
name=$7     # Name for the output
mode=$8     # Type of data to be used
sqanti_dir=$9 # Path to the SQANTI3 output
sqanti_prefix=${10} # Prefix of the SQANTI3 outputs
chr=${11}      # Do for only one chromosome

tmp_file="FALSE"
cd $wd

echo "INPUTS INTRODUCIDOS:"
    echo -e "\tgtf/gff complete path: $gff"
    echo -e "\tUTR: $utr"
    echo -e "\tSource: $src"
    echo -e "\tPriority: $pri"
    echo -e "\tTrust the complete exon and introns or used as support: $part"
    echo -e "\tPath of the gtf file directory: $wd":
    echo -e "\tName for the outputs: $name"
    echo -e "\tMode: $mode"
    echo -e "\tDirectorio output SQANTI: $sqanti_dir"
    echo -e "\tPrefijo output SQANTI: $sqanti_prefix"
    echo -e "\tChromosome (optional) Do only for one chromosome ej: chr19"

# Filter one chromosome from the original gtf
if [ -n "$chr" ]
then
    grep $chr $gff > tmp.gff
    gff="tmp.gff"
fi

module purge && module load anaconda

conda activate sqanti3_lrgasp
# Use the SQANTI3 classification file to keep only the protein 
if [ "$mode" == "transcript" ]
then
    Rscript  /home/crisag/WTC11_lr/transcriptome/carpetas_mal/generate_hints/filterClassification.R $sqanti_dir $sqanti_prefix $wd
    tail -n +2 filtered_${sqanti_prefix}_classification.txt | cut -f1 > tmp.lst
    python /home/crisag/WTC11_lr/transcriptome/generate_hints/filter_gtf.py tmp.lst $gff `pwd`
    gff=filtered_$(basename ${gff})
    #rm tmp.lst *classification.txt
    tmp_file="TRUE"
fi
conda activate busco
# add explicit introns
# If the model was trained to use UTR keep exons and CDS
if [ "$utr"  == "TRUE" ]
then
    grep -P "\t(CDS|exon)\t" $gff | ~/.conda/envs/sqanti3_lrgasp/scripts/gtf2gff.pl --printIntron --out=tmp.gff
    grep -P "\t(CDS|intron|exon)\t" tmp.gff > tmp2.gff
# If the model was't trained to use UTR keep only the CDS
else
    grep -P "\t(CDS)\t" $gff | ~/.conda/envs/sqanti3_lrgasp/scripts/gtf2gff.pl --printIntron --out=tmp.gff
    head tmp.gff
    grep -P "\t(CDS|intron)\t" tmp.gff > tmp2.gff
fi
rm tmp.gff

# Remove gene_id and change transcript id for grp_id
sed -i 's/gene_id[^;]*;//g' tmp2.gff
sed -i 's/transcript_id \"/grp=/g' tmp2.gff

# change the trancript id for the source
cat tmp2.gff | sed 's/";/;pri=1;src=PB/g' > $name.hits.gff
rm tmp2.gff

if [ $part == "FALSE" ]
then
    sed -i "s/exon/exonpart/g" $name.hits.gff
    sed -i "s/intron/intronpart/g" $name.hits.gff
    sed -i "s/CDS/CDSpart/g" $name.hits.gff
fi

if [ $tmp_file == "TRUE" ]
then
    echo "no gff"
#    rm $gff
fi

module unload anaconda

date
