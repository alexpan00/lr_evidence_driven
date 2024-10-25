#!/bin/bash
#SBATCH --job-name=sort_augustus_f_bam # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=sort_augustus_filtered_bam_%j.log # Standard output and error log

# Script to sort filtered sorted BAM after AUGUSTUS filterBam script (pairend data) was used

date;pwd

module purge && module load samtools

samtools sort muestras_wtc11_merged.ssf.bam -o muestras_wtc11_merged.s.final.bam

date

module unload samtools
