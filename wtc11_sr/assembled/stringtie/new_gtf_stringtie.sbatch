#!/bin/bash
#SBATCH --job-name=convert # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4 # Number of tasks = cpus
#SBATCH --mem-per-cpu=5G # Job memory request
#SBATCH --time=0-05:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=convert_stringtie_wtc11_sr_%j.log # Standard output and error log

#Script for filtering stranded gtf lines

#INPUT
file_in=$1
file_out=$2

echo "Input file:" $file_in
echo "Output file:" $file_out

date;pwd

/home/crisag/muestras_wtc11_sr/protocol2_sr_assembled/stringtie/get_lines.sh $file_in $file_out

date

