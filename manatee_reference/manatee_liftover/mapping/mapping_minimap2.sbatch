#!/bin/bash
#SBATCH --job-name=mapping
#SBATCH --output=mapping_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
#SBATCH --time=2-00:00:00
#SBATCH --qos=medium
#SBATCH --mail-type=ALL


## INPUTS:
reads=$1
genome=$2
out_name=$3

echo "INPUTS:"
echo "  Reads: $reads"
echo "  Genome: $genome"
echo "  Output prefix: $out_name"

date;pwd

module purge && module load anaconda

conda activate minimap2

#Mapping to the reference genome:

echo "Map the reference manatee cds to genome"

minimap2 -ax splice:hq -uf --MD $genome $reads > $out_name.sam

conda deactivate

module unload anaconda

date
