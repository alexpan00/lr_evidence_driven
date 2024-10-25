#!/bin/bash
#SBATCH --job-name=subsampling
#SBATCH --output=subsampling_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=1-00:00:00
#SBATCH --qos=short
#SBATCH --mail-type=NONE

file=$1
frac_file=$2
out_name=$3

echo "INPUTS:"
echo "  File (flnc) to divide: $file"
echo "  Fraction file (with the subsampling fractions needed): $frac_file"
echo "  Output name: $out_name"

module purge && module load samtools

pwd ; date

echo "Split file:"

while read -r line
do
	fraction="$line"
	samtools view -s $fraction --subsample-seed 123 $file -o $out_name.$fraction.flnc.bam
done < "$frac_file"

module unload samtools

date
