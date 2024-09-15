#!/bin/bash
#SBATCH --job-name=get_gtf
#SBATCH --output=get_gtf_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=10G
#SBATCH --time=1-00:00:00
#SBATCH --qos=short
#SBATCH --mail-type=ALL

date;pwd

module purge && module load anaconda

python /home/crisag/manatee_reference/get_gff_final/get_gtf_genes.py

module unload anaconda

date
