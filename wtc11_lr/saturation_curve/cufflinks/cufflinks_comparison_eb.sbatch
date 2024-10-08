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
dir_augustus_hints=$1
reference_gtf=$2
main_dir=$(pwd)

echo "-- INVARIABLE INPUTS:"
echo "  Main hints' output directory (general): $dir_augustus_hints"
echo "  Reference GTF: $reference_gtf"
echo "  Main directory where files will be stored: $main_dir"

date;pwd

module purge && module load anaconda

conda activate cufflinks

for dir in "$dir_augustus_hints"/*; do
	if [ -d "$dir" ]; then
		name_file=$(echo $dir | cut -d "/" -f 9 | cut -d "." -f1)
		if [ "$name_file" == 0 ] ; then
			name=$(echo $dir | cut -d "/" -f 9 | cut -d "." -f2)
			name_file="0.$name"
		fi
		gtf=$dir/filtered_${name_file}.sqanti_corrected_chr19_CDS.gtf.cds.gff
		out_dir="$main_dir/$name_file"
		echo "-- SPECIFIC INPUTS: --"
		echo "  AUGUSTUS hints output directory: $dir"
		echo "  GTF file used: $gtf"
		echo "  Output name: ${name_file}_cufflinks"
		echo "  Output directory: $out_dir"
		echo "------------------------------"
		echo "Creating the output directory: $out_dir"
                mkdir $out_dir
		cd $out_dir
		date
                echo "--RUN CUFFCOMPARE--"
		cuffcompare -e 0 -d 0 -T -o ${name_file}_cufflinks -r $reference_gtf $gtf
		echo "--FINISHED--"
		date
	fi
done

conda deactivate
module unload anaconda

date
