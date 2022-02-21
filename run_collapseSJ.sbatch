#!/bin/bash
#SBATCH --job-name=collapseSJ # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-02:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=sortSJ.log # Standard output and error log

source activate flair_env

# Script para colapsar las splice junctions resultado de mapear varias meustras
# utilizando STAR

# PATHS
utilities="/home/apadepe/utilities/"

# Argumentos
in_dir=$1

# Ir al directorio que contiene las SJ
cd $in_dir

# Combinar todos los fichero de SJ
cat *SJ.out.tab > compelteSJ.out.tab

# Ordenar el fichero
bedtools sort -i compelteSJ.out.tab > sorted_completeSJ.out.tab
rm compelteSJ.out.tab

# colapsar las SJ
python3 ${utilities}collapseSJ.py $in_dir/sorted_completeSJ.out.tab
