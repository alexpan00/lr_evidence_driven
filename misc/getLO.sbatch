#!/bin/bash
#SBATCH --job-name=LO # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-12:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=LO.log # Standard output and error log

# Script to generate LO transcript gtf from gtf. The GTF must include the
# StopCodon as part of the CDS. This script requires cufflinks and biopython.

# PATH
# check if script is started via SLURM or bash
# if with SLURM: there variable '$SLURM_JOB_ID' will exist
# `if [ -n $SLURM_JOB_ID ]` checks if $SLURM_JOB_ID is not an empty string
if [ -n $SLURM_JOB_ID ];  then
    # check the original location through scontrol and $SLURM_JOB_ID
    SCRIPT_PATH=$(scontrol show job ${SLURM_JOB_ID} | grep Command | cut -f2 -d"=" | cut -f1 -d" ")
    echo $SCRIPT_PATH
else
    # otherwise: started with bash. Get the real location.
    SCRIPT_PATH=$(realpath -s $0)
fi

utilities=$(dirname $(dirname $SCRIPT_PATH))

# Check args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Script to get longest ORF transcript from each transcript."
    echo "Args:"
    echo -e "\tgtf/gff complete path"
    echo -e "\tReference genome"
    exit 0
fi

pwd;date


# INPUTS
gff=$1      # gtf to be filtered
genome=$2   # reference genome

# Convert transcript to fasta
gffread $gff -g $genome -w transcript.fasta

# Get the longest transcript for each gene with a valid start and stop codon
python $utilities/misc/filterLO.py

# Get the id for each transcript
grep ">" transcript_LO.fasta | cut -f1 -d" " | cut -f2 -d">" > id.lst

# Filter the GTF
python $utilities/filters/filter_gtf.py id.lst $gff `pwd`

# Translate the longest ORF transcripts
python $utilities/misc/translate.py

rm id.lst transcript.fasta