#!/bin/bash
#SBATCH --job-name=cufflinks # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=cufflinks_%j.log # Standard output and error log

#Script to get the stats from an input gtf and a reference gtf

date;pwd

#INPUTS:
input_gtf=$1
reference_gtf=$2
out_name=$3

echo "INPUTS:"
echo "  Input GTF: $input_gtf"
echo "  Reference GTF: $reference_gtf"
echo "  Output name: $out_name"

module purge && module load anaconda

conda activate cufflinks

cuffcompare -e 0 -d 0 -T -o $out_name -r $reference_gtf $input_gtf

date

conda deactivate
module unload anaconda
