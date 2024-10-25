#!/bin/bash
#SBATCH --job-name=cufflinks # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=cufflinks_%j.log # Standard output and error log

# Script to get the stats from the generated gtf of augustus and a reference gtf

date;pwd

module purge && module load anaconda
conda activate cufflinks

cuffcompare -e 0 -d 0 -T -o cufflinks_comparison_wtc11_sr -r /storage/gge/Alejandro/WTC11/filtered_modificado_chr19_CDS.gtf /home/crisag/muestras_wtc11_sr/protocol2_sr_assembled/augustus/output_augustus/wtc11_sr_filtered_2.gtf

date

conda deactivate
module unload anaconda
