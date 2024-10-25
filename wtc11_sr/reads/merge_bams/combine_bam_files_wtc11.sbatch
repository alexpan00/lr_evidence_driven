#!/bin/bash
#SBATCH --job-name=combine_map_reads # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=combine_%j.log # Standard output and error log

#Script for merging multiple bam files

date;pwd

module purge && module load samtools

samtools merge muestras_wtc11_merged.bam /storage/gge/Alejandro/WTC11/Illumina/trimmed/ENCBS474NOC/map_out/ENCBS474NOCAligned.sortedByCoord.out.bam /storage/gge/Alejandro/WTC11/Illumina/trimmed/ENCBS593PKA/map_out/ENCBS593PKAAligned.sortedByCoord.out.bam /storage/gge/Alejandro/WTC11/Illumina/trimmed/ENCBS944CBA/map_out/ENCBS944CBAAligned.sortedByCoord.out.bam

date

module unload samtools
