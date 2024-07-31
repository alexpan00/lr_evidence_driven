#!/bin/bash
#SBATCH --job-name=UJC_class
#SBATCH --time 10:00:00
#SBATCH --qos=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10gb
#SBATCH --output=logs/7_UJC_class.out
#SBATCH --error=logs/7_UJC_class.err
#SBATCH --array=0-0

# join the UJC file and the clasification file

join --nocheck-order -j 1 -t$'\t' <(sort -k1,1 combined_ONT/ONT_UJC.txt) <(tail -n +2 combined_ONT/ONT_classification.txt | cut -f1,6 | sort -k1,1) > combined_ONT/ONT_UJC_class.txt


join --nocheck-order -j 1 -t$'\t' <(sort -k1,1 combined_PB/PB_UJC.txt) <(tail -n +2 combined_PB/PB_classification.txt | cut -f1,6 | sort -k1,1) > combined_PB/PB_UJC_class.txt
