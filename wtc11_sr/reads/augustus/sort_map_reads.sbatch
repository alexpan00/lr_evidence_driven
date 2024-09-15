#!/bin/bash
#SBATCH --job-name=sort_map_reads # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=0-03:50:00 # Time limit days-hrs:min:sec
#SBATCH --output=sorting%j.log # Standard output and error log

#Script for sorting concatenated mapped reads

date;pwd

module purge && module load samtools

samtools sort -n muestras_wtc11_merged.bam > muestras_wtc11_merged.s.bam


date

module unload samtools
