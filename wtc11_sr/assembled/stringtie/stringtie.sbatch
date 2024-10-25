#!/bin/bash
#SBATCH --job-name=stringtie_wtc11_sr # Job name
#SBATCH --qos=medium # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4 # Number of tasks = cpus
#SBATCH --mem-per-cpu=5G # Job memory request
#SBATCH --time=5-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=stringtie_wtc11_sr_%j.log # Standard output and error log

#Script to run stringtie

#INPUT
bam_s=$1
out_name=$2

echo "INPUTS:"
echo " BAM file:" $bam_s
echo " Output name:" $out_name

date;pwd

module purge && module load anaconda

conda activate stringtie

stringtie -p 4 -o $out_name.gtf $bam_s

date

conda deactivate
module unload anaconda
