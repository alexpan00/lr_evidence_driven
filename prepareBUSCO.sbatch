#!/bin/bash
#SBATCH --job-name=prepareBUSCO # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-24:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=prepare_busco.log # Standard output and error log

# PATHS
utilities="/home/apadepe/utilities"

# ARGS
busco_seqs=$1 # Path con las secuencias de los genes BUSCO
busco_gff=$2 # Path con los gff de los genes BUSCO
out_dir=$3 

source activate SQANTI3.env

# Obtener las secuencias en formato faa de los BUSCOS completos
python $utilities/busco_complete_aa.py $busco_seqs $out_dir


cd $out_dir
conda activate busco
# Colapsar las secuencias con una identidad mayor al 80 %
cd-hit -o complete_buscos.cdhit -c 0.8 -i complete_buscos.faa -p 1 -d 0 -T 4 -M 48000
grep ">" complete_buscos.cdhit | cut -f2 -d">" | cut -f1 > cdhit.lst

# Concatenar los gff de los genes que se han mantenido después del colapso
python $utilities/concatenateGFF.py cdhit.lst $busco_gff





