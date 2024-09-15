#!/bin/bash
#SBATCH --job-name=index # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=0-05:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=create_index_%j.log # Standard output and error log

# Script to create genome index

date;pwd

module purge && module load anaconda

conda activate tophat2

bowtie2-build --large-index -f /storage/gge/Alejandro/WTC11/lrgasp_grch38_sirvs.fasta /home/crisag/muestras_wtc11_sr/protocol2_sr_assembled/mapping_tophat2/genome_index/index

date

module unload anaconda
