#!/bin/bash
#SBATCH --job-name=preprocess_cluster
#SBATCH --output=cluster_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --qos=medium
#SBATCH --mail-type=ALL

#Script to perform isoseq cluster2:

#INPUTS:
dir_fofn="$1"
out_dir="$2"

#Imprimir los inputs:
echo "INPUTS:"
echo "  fofn directorio: $dir_fofn"
echo "  Output directory with the outpus: $out_dir"

pwd ; date

module purge && module load anaconda

conda activate preprocess

# Check if the target is not a directory
if [ ! -d "$dir_fofn" ]; then
	echo "Not a directory"
fi

# Loop through files in the target directory
for file in "$dir_fofn"/*; do
	if [ -f "$file" ]; then
		echo "fofn file used: $file"
		name_file=$(echo $file | cut -d "/" -f 9 | cut -d "_" -f1)
		echo "Out name of the file: $name_file"
		echo "Run isoseq cluster2:"
		isoseq cluster2 $file $out_dir/$name_file.clustered.bam
	fi
done

conda deactivate

module unload anaconda

date
