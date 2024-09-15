#!/bin/bash
#SBATCH --job-name=gethints_augustus # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=get_hints_augustus_%j.log # Standard output and error log

# Script to get the intron gff file (also known as hints file)

date;pwd

module purge && module load anaconda
conda activate augustus

bam2hints --intronsonly --in=muestras_wtc11_merged.s.final.bam --out=introns_wtc11_hints.gff

date

conda deactivate
module unload anaconda
