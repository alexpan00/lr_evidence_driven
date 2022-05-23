#!/bin/bash
#SBATCH --job-name=optimize # Job name
#SBATCH --partition=long # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=8 # Number of tasks = cpus
#SBATCH --mem-per-cpu=2gb # Job memory request
#SBATCH --time=7-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=Optimize.log # Standard output and error log

source activate busco
genes="/home/apadepe/TFM/WTC11/AUGUSTUS/Isoseq_PB/AUGUSTUS/testFR/fr1000/results/filtered_subsets/subset_5000_WTC11_PB_fr1000.f.gb"
optimize_augustus.pl --species=subset_5000_WTC11_PB_fr1000 --rounds=3 $genes --UTR=on \
--metapars=/home/apadepe/utilities/misc/subset_5000_WTC11_PB_fr1000/subset_5000_WTC11_PB_fr1000_metapars.utr.cfg \
--trainOnlyUtr=1 --cpus=8
