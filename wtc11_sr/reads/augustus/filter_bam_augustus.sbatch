#!/bin/bash
#SBATCH --job-name=filterbam_augustus # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=filterbam_augustus_%j.log # Standard output and error log

# Script to run AUGUSTUS filterBam script (pairend data)

date;pwd

module purge && module load anaconda
conda activate augustus

filterBam --uniq --paired --pairwiseAlignment --in muestras_wtc11_merged.s.bam --out muestras_wtc11_merged.ssf.bam

date

conda deactivate
module unload anaconda
