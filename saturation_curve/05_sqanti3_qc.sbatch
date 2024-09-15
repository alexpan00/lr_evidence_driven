#!/bin/bash
#SBATCH --job-name=sqanti_qc
#SBATCH --output=sqanti_qc_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=50G
#SBATCH --time=4-00:00:00
#SBATCH --qos=medium
#SBATCH --mail-type=ALL

export PYTHONPATH=$PYTHONPATH:/home/crisag/SQANTI3-5.2/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/home/crisag/SQANTI3-5.2/cDNA_Cupcake/

#INPUTS:
dir_collapse=$1
gtf_reference=$2
genome=$3
SJ_sr=$4
out_dir=$(pwd | cut -d "/" -f 1-6)

echo "INVARIABLE INPUTS:"
echo "  Isoseq collapse directory: $dir_collapse"
echo "  Reference GTF file: $gtf_reference"
echo "  Genome: $genome"
echo "  Main output directory: $out_dir"
echo "  Spliced-junctions: $SJ_sr"

module purge && module load anaconda

conda activate SQANTI3.env

pwd ; date

for dir in "$dir_collapse"/*; do
        if [ -d "$dir" ]; then
		name_file=$(echo $dir | cut -d "/" -f 8 | cut -d "." -f1)
		if [ "$name_file" == 0 ] ; then
			name=$(echo $dir | cut -d "/" -f 8 | cut -d "." -f2)
			name_file="0.$name"
		fi
		fasta=$dir/$name_file.collapsed.fasta
		out_dir_final="$out_dir/output_sqanti3_qc/$name_file"
		fl_counts="$dir/$name_file.collapsed.flnc_count_tab.txt"
		echo "Creating the output directory: $out_dir_final"
		mkdir $out_dir_final
		echo "-- Starting run de SQANTI: --"
		echo "SPECIFIC INPUTS:"
		echo "  File directory: $dir"
                echo "  FASTA file used: $fasta"
                echo "  Output name: $name_file.sqanti"
		echo "  Output directory: $out_dir_final"
		echo "  PB counts (--fl_counts): $fl_counts"
		echo "-Run SQANTI:-"
		python /home/crisag/SQANTI3-5.2/sqanti3_qc.py --fasta $fasta $gtf_reference $genome -c $SJ_sr -d $out_dir_final -o $name_file.sqanti --fl $fl_counts -t 10
	fi
done
conda deactivate

module unload anaconda

date
