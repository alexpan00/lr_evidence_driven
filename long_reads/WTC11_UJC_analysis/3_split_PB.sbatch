#!/bin/bash
#SBATCH --job-name=splitting_gtf_PB
#SBATCH --time=1:00:00
#SBATCH --qos=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=30gb
#SBATCH --output=splitting_gtf_PB_%A_%a.out
#SBATCH --error=splitting_gtf_PB_%A_%a.err


# Script to map and split PacBio flnc reads
pwd; date
module load samtools
source activate sq3


mkdir splitted_PB
dir="/home/apadepe/lr_pipelines/SQANTI3/utilities/"
out_dir="splitted_PB"

# Define reference assembly 
assembly="/home/apadepe/practicas/reference_human/lrgasp_grch38_sirvs.fasta"

# Output of the isoseq refine step
reads="/storage/gge/Alejandro/WTC11/PacBio/isoseq_output/flnc.fastq" # PacBio

# map using minimap2
minimap2 -ax splice:hq -uf --MD -t 32 ${assembly} ${reads} > flnc.sam

# SAM to GTF
samtools view -bS -F0x900 flnc.sam | samtools sort -o flnc_primary_aln_sorted.bam 
source activate test_is3
spliced_bam2gff -t 1000000 -M flnc_primary_aln_sorted.bam > flnc.gff

# From GTF to GenePred (download script from UCSC tools)
${dir}/gtfToGenePred flnc.gff flnc.genepred

# Split GTF into 50 GenePred files
split --number=l/50 flnc.genepred ${out_dir}/PB_splitted_genepred_

# 50 GenePred (per sample) into GTF again
arr=`find "${out_dir}" -name "*splitted_genepred*"`
for splitted_genepred in $arr
do
        # Download script from UCSC tools
        ./genePredToGtf file ${splitted_genepred} ${splitted_genepred}.gtf
done

ls ${out_dir}/*.gtf > PB_splitted.fofn