#!/bin/bash
#SBATCH --job-name=get_UJC_Iso-seq
#SBATCH --time 10:00:00
#SBATCH --qos=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100gb
#SBATCH --output=logs/get_UJC.out
#SBATCH --error=logs/get_UJC.err
#SBATCH --array=0-0

# This script takes gtf to create UJC

source activate gtftools 
module load bedtools

# PacBio
echo "UJC PacBio"

# outdir
outdir="/home/apadepe/reads_manatee/combined_PB"
mkdir $outdir
gtf_file="/home/apadepe/reads_manatee/combined_PB/PB_corrected.gtf"

# Get introns
gtftools -i ${outdir}/PB_introns.bed ${gtf_file}

# Get UJC 
awk -F'\t' -v OFS="\t" '{print $5,"chr"$1,$4,$2+1"_"$3}' ${outdir}/PB_introns.bed | bedtools groupby -g 1 -c 2,3,4 -o distinct,distinct,collapse | sed 's/,/_/g' | awk -F'\t' -v OFS="\t" '{print $1,$2"_"$3"_"$4}' > ${outdir}/PB_UJC.txt

# remove intermidiate files
rm ${outdir}/PB_introns.bed
rm ${gtf_file}.ensembl

#ONT
echo "UJC ONT"

# outdir
outdir="/home/apadepe/reads_manatee/combined_ONT"
mkdir $outdir
gtf_file="/home/apadepe/reads_manatee/combined_ONT/ONT_corrected.gtf"


# Get introns
gtftools -i ${outdir}/ONT_introns.bed ${gtf_file}

# Get UJC 
awk -F'\t' -v OFS="\t" '{print $5,"chr"$1,$4,$2+1"_"$3}' ${outdir}/ONT_introns.bed | bedtools groupby -g 1 -c 2,3,4 -o distinct,distinct,collapse | sed 's/,/_/g' | awk -F'\t' -v OFS="\t" '{print $1,$2"_"$3"_"$4}' > ${outdir}/ONT_UJC.txt

# remove intermidiate files
rm ${outdir}/ONT_introns.bed
rm ${gtf_file}.ensembl

