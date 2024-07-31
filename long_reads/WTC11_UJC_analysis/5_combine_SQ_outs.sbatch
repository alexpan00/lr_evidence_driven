#!/bin/bash
#SBATCH --job-name=combine_outs
#SBATCH --output=logs/combine_outs_%A_%a.out 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=15gb
#SBATCH --qos=short
#SBATCH --time=10:00:00
#SBATCH --array=0

pwd; date

# Combien the outputs of the splitted runs

# Start with PB data
echo "PacBio"
out_dir="combined_PB" # final combined dir
class_fofn="PB_class.fofn" # fofn pacbio classification files
classification="PB_classification.txt" # final classification file
gtf_fofn="PB_gtf.fofn" # fofn pacbio gtf files
gtf="PB_corrected.gtf" # final gtf file

mkdir $out_dir

# generate the fofn
ls SQANTI_PB/PB_splitted_genepred_*/*classification.txt > $class_fofn
ls SQANTI_PB/PB_splitted_genepred_*/*corrected.gtf > $gtf_fofn


echo "merging classification file"
head -n 1 $(head -n 1 ${class_fofn}) > ${out_dir}/${classification}
cat $class_fofn | xargs -I {} tail -n +2 {} >> ${out_dir}/${classification}

echo "merging gtf file"
cat $(cat $gtf_fofn) >> ${out_dir}/${gtf}

# ONT
echo "ONT"
out_dir="combined_ONT"
class_fofn="ONT_class.fofn"
classification="ONT_classification.txt"
gtf_fofn="ONT_gtf.fofn"
gtf="ONT_corrected.gtf"

mkdir $out_dir

ls SQANTI_ONT/ONT_splitted_genepred_*/*classification.txt > $class_fofn
ls SQANTI_ONT/ONT_splitted_genepred_*/*corrected.gtf > $gtf_fofn

echo "merging classification file"
head -n 1 $(head -n 1 ${class_fofn}) > ${out_dir}/${classification}
cat $class_fofn | xargs -I {} tail -n +2 {} >> ${out_dir}/${classification}

echo "merging gtf file"
cat $(cat ${gtf_fofn}) >> ${out_dir}/${gtf}

pwd;date