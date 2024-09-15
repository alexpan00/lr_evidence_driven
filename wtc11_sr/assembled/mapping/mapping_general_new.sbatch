#!/bin/bash
#SBATCH --job-name=mapping # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=mapping_sr_wtc11_%j.log # Standard output and error log

# Script to align paired-end data to genome

date;pwd

out_map=$1
r1=$2
r2=$3

#Print outputs

echo "Output mapping directory: " $out_map
echo "r_1: " $r1
echo "r_2: " $r2

module purge && module load anaconda

conda activate tophat2

tophat -r 400 --no-discordant --no-mixed --output-dir $out_map /home/crisag/muestras_wtc11_sr/protocol2_sr_assembled/mapping/genome_index/index/index $r1 $r2

date

module unload anaconda
