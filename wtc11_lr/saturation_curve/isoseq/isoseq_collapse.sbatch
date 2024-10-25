#!/bin/bash
#SBATCH --job-name=isoseq_collapse
#SBATCH --output=isoseq_collapse_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=50G
#SBATCH --time=10:00:00
#SBATCH --qos=short
#SBATCH --mail-type=ALL

#Script to perform isoseq collapse:

#INPUTS:
dir_map=$1
out_dir=$(pwd)

echo "INPUTS:"
echo "  Mapping directory: $dir_map"
echo "  Main output directory where directories will be created: $out_dir"

pwd;date

module purge && module load anaconda

conda activate preprocess

for dir in "$dir_map"/*; do
	echo "Begging of a new process:"
        if [ -d "$dir" ]; then
                echo "File's directory: $dir"
                name_file=$(echo $dir | cut -d "/" -f 7 | cut -d "." -f1)
                if [ "$name_file" == 0 ] ; then
                        name=$(echo $dir | cut -d "/" -f 7 | cut -d "." -f2)
                        name_file="0.$name"
                fi
                mapped_bam=$dir/$name_file.clustered.hq.mapped.bam
                echo "Mapped BAM file used: $mapped_bam"
                echo "Out name of the file: $name_file"
                echo "Make a dir with that name: $out_dir/$name_file"
                mkdir $out_dir/$name_file
                echo "Run isoseq collapse:"
                isoseq collapse --do-not-collapse-extra-5exons --max-5p-diff 5 --max-3p-diff 5 $mapped_bam $out_dir/$name_file/$name_file.collapsed.gff
        fi
done

module unload anaconda

pwd;date
