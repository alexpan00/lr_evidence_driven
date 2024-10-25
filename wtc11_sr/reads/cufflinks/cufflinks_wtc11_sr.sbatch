#!/bin/bash
#SBATCH --job-name=cufflinks # Job name
#SBATCH --qos=medium # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=2-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=cufflinks_%j.log # Standard output and error log

# Script to obtain cufflinks' stats

date;pwd

module purge && module load anaconda
conda activate cufflinks

cuffcompare -e 0 -d 0 -T -o cufflinks_comparison_wtc11_sr -r /storage/gge/Alejandro/WTC11/filtered_modificado_chr19_CDS.gtf /home/crisag/muestras_wtc11_sr/protocol1_sr_no_filtering/output_augustus/wtc11.gtf

date

conda deactivate
module unload anaconda
