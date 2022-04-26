#!/bin/bash
#SBATCH --job-name=optimize # Job name
#SBATCH --partition=long # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=8 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=10-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=Optimize.log # Standard output and error log

source activate busco

optimize_augustus.pl --species=subset_4000_WTC11_MIX_fr1000 --rounds=3 subset_4000_WTC11_MIX_fr1000.f.gb --UTR=on \
--metapars=$AUGUSTUS_CONFIG_PATH/species/subset_4000_WTC11_MIX_fr1000/subset_4000_WTC11_MIX_fr1000_metapars.utr.cfg \
--trainOnlyUtr=1 --cpus=8
