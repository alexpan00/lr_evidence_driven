#!/bin/bash
#SBATCH --job-name=mapping
#SBATCH --output=mapping_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
#SBATCH --time=2-00:00:00
#SBATCH --qos=medium
#SBATCH --mail-type=ALL

#Script to map reads to a genome:

#INPUTS:
dir_cluster=$1
genome=$2
out_dir=$(pwd)

echo "INPUTS:"
echo "  Directory where clustering files are located: $dir_cluster"
echo "  Genome used for the mapping process: $genome"
echo "  Current directory (where files will be stored and saved): $out_dir"

pwd ; date

module purge && module load anaconda

conda activate pbmm2

for file in "$dir_cluster"/*.clustered.bam; do
	if [ -f "$file" ]; then
		echo "BAM file used: $file"
		name_file=$(echo $file | cut -d "/" -f 9 | cut -d "." -f1)
		if [ $name_file == 0 ] ; then
			name=$(echo $file | cut -d "/" -f 9 | cut -d "." -f2)
			name_file="0.$name"
		fi
		echo "Output name: $name_file"
		echo "Make a dir with that name:"
		mkdir $out_dir/$name_file
		echo "Run isoseq pbmm2:"
		pbmm2 align --preset ISOSEQ --sort $file $genome $out_dir/$name_file/$name_file.clustered.hq.mapped.bam
        fi
done

module unload anaconda

date
