#!/bin/bash
#SBATCH --job-name=filter_primary_al
#SBATCH --output=filter_primary_alignment_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --time=2-00:00:00
#SBATCH --qos=medium
#SBATCH --mail-type=ALL


## INPUTS:
reads_dir=$1
filename=$2

echo "INPUTS:"
echo "  Reads' directory: $reads_dir"
echo "  File's name: $filename"

date;pwd

module purge && module load samtools

#Filter primary alignment:

echo "Get primary alignment"

samtools view -bS -F0x900 ${reads_dir}/${filename}.sam | samtools sort -o ${reads_dir}/${filename}_primary_aln_sorted.bam

module unload samtools

date
