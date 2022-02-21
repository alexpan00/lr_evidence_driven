#!/bin/bash
#SBATCH --job-name=class2GB # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-02:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=class2GB.log # Standard output and error log

# Script que permite ir desde el arhivo classification de salida de
# SQANTI3 hasta los tránscritos filtrados y colapsados en formato GB

source activate lrgasp2
# PATHS
utilities="/home/apadepe/utilities"
tama_dir="/home/apadepe/lr_pipelines/tama/"
genoma="/storage/gge/Alejandro/reference_manatee/lrgasp_manatee_sirv1.fasta"

# ARGS
sqanti_output_dir=$1 # Directorio de salida d elos output de SQANTI3
sqanti_prefix=$2 # Prefijo de los output de SQANTI3
out_dir=$3 # Directorio para los ficheros de salida

# Filtrado del classification
Rscript $utilities/filterClassification.R $sqanti_output_dir $sqanti_prefix $out_dir

# Filtrado del sam del mapeo de los tránscritos a partir del classification
python $utilities/filter_sam.py ${out_dir}/filtered_${sqanti_prefix}_classification.txt \
    ${sqanti_output_dir}/${sqanti_prefix}_corrected.sam $out_dir

# Uso del sam filtrado para el colapso utilizando TAMA
conda activate tama
cd $out_dir
python ${tama_dir}tama_collapse.py -s fitered_${sqanti_prefix}_corrected.sam -f $genoma\
    -p $out_dir/${sqanti_prefix} -x no_cap -m 100 -z 100

