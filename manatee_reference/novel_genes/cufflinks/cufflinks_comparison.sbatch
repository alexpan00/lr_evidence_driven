#!/bin/bash
#SBATCH --job-name=cufflinks # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=cufflinks_%j.log # Standard output and error log

# Script to get the stats from the generated gtf and a reference gtf

#INPUTS:
gtf_input=$1
gtf_ref=$2
out_name=$3

echo "--INPUTS:--"
echo "Input GTF: $gtf_input"
echo "Reference GTF: $gtf_ref"
echo "Output name: $out_name"

date;pwd

module purge && module load anaconda
conda activate cufflinks

cuffcompare -e 0 -d 0 -G -o $out_name  -r $gtf_ref $gtf_input

conda deactivate
module unload anaconda

date
