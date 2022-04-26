#!/bin/bash
#SBATCH --job-name=test_isoseq # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-12:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=isoseq_test.log # Standard output and error log

source activate busco
# PATH
#test_file="/home/apadepe/TFM/pipeline_BUSCO_AUGUSTUS/flanking_region_10000/subsets/filtered_subset/complete_buscos_test.f.gb"
utilities="/home/apadepe/utilities/"

mkdir output_utr
augustus --species=subset_4000_FLAIR_MIX_fr1000 \
    /home/apadepe/practicas/reference_human/chr19.fa \
    --protein=off --UTR=on --print_utr=on > output_utr/subset_ON_FLAIR_MIX_fr1000.gtf

