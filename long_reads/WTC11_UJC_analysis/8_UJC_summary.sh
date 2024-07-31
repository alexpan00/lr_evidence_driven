#!/bin/bash
#SBATCH --job-name=UJC_summary
#SBATCH --time 10:00:00
#SBATCH --qos=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10gb
#SBATCH --output=logs/8_UJC_summary.out
#SBATCH --error=logs/8_UJC_summary.err
#SBATCH --array=0-0

# join the UJC file and the clasification file
paste <(cut --output-delimiter="_" -f 2,3 combined_PB/PB_UJC_class.txt) <(cut -f3 combined_PB/PB_UJC_class.txt) | sort | uniq  > combined_PB/PB_unique_UJC.txt
cut -f2 combined_PB/PB_unique_UJC.txt | sort | uniq -c | awk '{print $2 "\t" $1}' > combined_PB/unique_UJC_categories.txt


paste <(cut --output-delimiter="_" -f 2,3 combined_ONT/ONT_UJC_class.txt) <(cut -f3 combined_ONT/ONT_UJC_class.txt) | sort | uniq  > combined_ONT/ONT_unique_UJC.txt
cut -f2 combined_ONT/ONT_unique_UJC.txt | sort | uniq -c | awk '{print $2 "\t" $1}' > combined_ONT/ONT_unique_UJC_categories.txt


# Combine PacBio and ONT results > MIX reads
cat combined_PB/PB_unique_UJC.txt combined_ONT/ONT_unique_UJC.txt > all_UJC.txt
sort all_UJC.txt | uniq | cut -f2 | sort | uniq -c | awk '{print $2 "\t" $1}' > mix_unique_UJC_categories.txt