#!/bin/bash
#SBATCH --job-name=splitting_gtf_ONT
#SBATCH --time=10:00:00
#SBATCH --qos=short
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50gb
#SBATCH --output=logs/splitting_gtf_ont_%A_%a.out
#SBATCH --error=logs/splitting_gtf_ont_%A_%a.err

conda activate test_is3
module load samtools
# Script for the UJC anlysis of ONT data starting from the aligned reads
mkdir splitted_ONT
dir="/home/apadepe/lr_pipelines/SQANTI3/utilities/"
out_dir="splitted_ONT"


bam_fofn="bam.fofn"

# BAM to GTF
samtools cat -b $bam_fofn -@ $SLURM_CPUS_PER_TASK | samtools sort -o ONT_aln_sorted.bam
spliced_bam2gff -t 1000000 -M ONT_aln_sorted.bam > ONT.gff


# From GTF to GenePred (download script from UCSC tools)
${dir}/gtfToGenePred ONT.gff ONT.genepred

# remove reads with unasigned strands
awk '($3 != ".")'  ONT.genepred > ONT_filtered.genepred

# Split GTF into 50 GenePred files
split --number=l/50 ONT_filtered.genepred ${out_dir}/ONT_splitted_genepred_

#50 GenePred (per sample) into GTF again
arr=`find "${out_dir}" -name "*splitted_genepred*"`
for splitted_genepred in $arr
do
        #Download script from UCSC tools
        ./genePredToGtf file ${splitted_genepred} ${splitted_genepred}.gtf
done

# get the offn of the gtf files to run SQANTI in the next step
ls ${out_dir}/*.gtf > ONT_splitted.fofn