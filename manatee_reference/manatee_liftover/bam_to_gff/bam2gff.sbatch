#!/bin/bash
#SBATCH --job-name=bam2gff
#SBATCH --output=bam2gff_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --time=1-00:00:00
#SBATCH --qos=short
#SBATCH --mail-type=ALL


## INPUTS:
bam_dir=$1
filename=$2
gff_dir=$3

echo "INPUTS:"
echo "  Sorted BAM directory: $bam_dir"
echo "  File's name: $filename"
echo "  GFF's directory"

date;pwd

module purge && module load anaconda

conda activate spliced_bam2gff

#Get GFF from BAM:

echo "Get GFF from BAM"

spliced_bam2gff -t 1000000 -M ${bam_dir}/${filename}_primary_aln_sorted.bam > ${gff_dir}/${filename}_primary_aln.gff

conda deactivate

module unload anaconda

date
