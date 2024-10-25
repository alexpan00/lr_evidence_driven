#!/bin/bash
#SBATCH --job-name=cufflinks # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=cufflinks_%j.log # Standard output and error log

#Script to get the stats from the generated gtf of augustus and a reference gtf

#INPUTS:
dir_augustus_output=$1
reference_gtf=$2
main_dir=$(pwd)

echo "-- INVARIABLES INPUTS:"
echo "  Main AUGUSTUS output directory: $dir_augustus_output"
echo "  Reference GTF file: $reference_gtf"
echo "  Main directory for the files to be stored: $main_dir"

date;pwd

module purge && module load anaconda

conda activate cufflinks

for dir in "$dir_augustus_output"/*; do
	if [ -d "$dir" ]; then
		name_file=$(echo $dir | cut -d "/" -f 8 | cut -d "." -f1)
		if [ "$name_file" == 0 ] ; then
			name=$(echo $dir | cut -d "/" -f 8 | cut -d "." -f2)
			name_file="0.$name"
		fi
		gtf_augustus=$dir/${name_file}.augustus_reduced.gtf
		out_dir="$main_dir/$name_file"
		echo "-- SPECIFIC INPUTS: --"
		echo "  AUGUSTUS output directory: $dir"
		echo "  AUGUSTUS GTF file used: $gtf_augustus"
		echo "  Output name: ${name_file}_cufflinks"
		echo "  Output directory: $out_dir"
		echo "------------------------------"
		echo "Creating the output directory with the name: $out_dir"
                mkdir $out_dir
		cd $out_dir
		date
                echo "--RUN CUFFCOMPARE--"
		cuffcompare -e 0 -d 0 -T -o ${name_file}_cufflinks -r $reference_gtf $gtf_augustus
		echo "--FINISHED--"
		date
	fi
done

conda deactivate
module unload anaconda

date
