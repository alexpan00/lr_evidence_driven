#!/bin/bash
#SBATCH --job-name=stringtie_wtc11_sr # Job name
#SBATCH --qos=medium # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4 # Number of tasks = cpus
#SBATCH --mem-per-cpu=5G # Job memory request
#SBATCH --time=5-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=stringtie_merge_%j.log # Standard output and error log

#Script for merging stringtie gtf

#INPUT
gtf_files=$1
out_name=$2


echo "INPUTS:"
echo " The file containing the GTFs to merge:" $gtf_files
echo " Output names:" $out_name

date;pwd

module purge && module load anaconda

conda activate stringtie

stringtie --merge -p 4 -o $out_name.gtf $gtf_files

date

conda deactivate
module unload anaconda
