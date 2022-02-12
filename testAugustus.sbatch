#!/bin/bash
#SBATCH --job-name=test_isoseq # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-02:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=isoseq_test.log # Standard output and error log

source activate busco
# PATH
#test_file="/home/apadepe/TFM/pipeline_BUSCO_AUGUSTUS/flanking_region_10000/subsets/filtered_subset/complete_buscos_test.f.gb"
utilities="/home/apadepe/utilities/"

# Argumentos
species=$1
test_file=$2
out_dir=$3

augustus --species=$species ${test_file} > $out_dir/$species.out


#bash ${utilities}get_stats.sh `pwd`
