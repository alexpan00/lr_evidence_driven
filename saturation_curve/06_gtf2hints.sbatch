#!/bin/bash
#SBATCH --job-name=create_hints # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=10G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=gtf2hints_%j.log # Standard output and error log

# Script to generate a hints file from a GTF file. Different kinds of sources
# can be specified
# check if script is started via SLURM or bash
# if with SLURM: there variable '$SLURM_JOB_ID' will exist
# `if [ -n $SLURM_JOB_ID ]` checks if $SLURM_JOB_ID is not an empty string
if [ -n "$SLURM_JOB_ID" ];  then
    # check the original location through scontrol and $SLURM_JOB_ID
    SCRIPT_PATH=$(scontrol show job ${SLURM_JOB_ID} | grep Command | cut -f2 -d"=" | cut -f1 -d" ")
else
    # otherwise: started with bash. Get the real location.
    SCRIPT_PATH=$(realpath -s $0)
fi
utilities=$(dirname $(dirname $SCRIPT_PATH))

# Check args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Script to generate hints from gtf file."
    echo "Args:"
    echo -e "\tSQANTI main dir"
    echo -e "\tUTR (TRUE/FALSE) include UTRS in the hints file"
    echo -e "\tSource (M,PB,...) the type of source used by AUGUSTUS"
    echo -e "\tPriority: used by AUGUSTUS in case of contradiction between hints"
    echo -e "\tTrust the complete exon and introns or used as support (TRUE/FALSE)"
    echo -e "\tMode: type of data that will be converted to hints."
    echo -e "\tCan be read, transcript or gene"
    echo -e "\tChromosome (optional) Do only for one chromosome ej: chr19"
    exit 0
fi

pwd;date

# INPUTS
dir_sqanti_output=$1      # Directorio principal del output de SQANTI
utr=$2      # include or exclude utr
src=$3      # Source of the information (M,PB)
pri=$4      # Priority
part=$5     # Trust the complete exon/intron
mode=$6     # Type of data to be used
chr=${7}      # Do for only one chromosome

out_dir=$(pwd | cut -d "/" -f 1-6)

module purge && module load anaconda

conda activate sqanti3_lrgasp

echo "-- FIX INPUTS: --"
echo "  Main SQANTI3 output dir: $dir_sqanti_output"
echo "  Incluide or excluide utr: $utr"
echo "  Source of information (M,PB): $src"
echo "  Priority: $pri"
echo "  Trust exon/intron complete: $part"
echo "  Type of data to use: $mode"
echo "  Do it for one chromosome: $chr"
echo "  Main directory: $out_dir"

for dir in "$dir_sqanti_output"/*; do
	if [ -d "$dir" ]; then
		name_file=$(echo $dir | cut -d "/" -f 8 | cut -d "." -f1)
		if [ "$name_file" == 0 ] ; then
			name=$(echo $dir | cut -d "/" -f 8 | cut -d "." -f2)
			name_file="0.$name"
		fi
		sqanti_prefix="$name_file.sqanti"
		gff=$dir/${sqanti_prefix}_corrected.gtf.cds.gff
		wd="$out_dir/output_hints/$name_file"
		echo "-- SPECIFIC INPUTS: --"
		echo "GTF file used: $gff"
		echo "Output SQANTI3 directory for each sample: $dir"
		echo "SQANTI3 prefix: $sqanti_prefix"
		echo "Output name: $name_file.hints"
		echo "Working directory (where the hints will be stored): $wd"
		echo "Creating the directory: $wd"
		mkdir $wd
		cd $wd
		echo "-- START GTF2HINTS--"
		tmp_file="FALSE"
		# Filter one chromosome from the original gtf
		if [ -n "$chr" ]; then
    			grep $chr $gff > tmp.gff
    			gff="tmp.gff"
		fi
		# Use the SQANTI3 classification file to keep only the protein
		if [ "$mode" == "transcript" ]
		then
    			Rscript  ~/WTC11_lr/saturation_curve/augustus/create_hints/filterClassification.R $dir $sqanti_prefix $wd
    			tail -n +2 filtered_${sqanti_prefix}_classification.txt | cut -f1 > tmp.lst
    			python ~/long_reads_augustus/filters/filter_gtf.py tmp.lst $gff `pwd`
    			gff=filtered_$(basename ${gff})
    			#rm tmp.lst *classification.txt
    			tmp_file="TRUE"
		fi

		# add explicit introns
		# If the model was trained to use UTR keep exons and CDS
		if [ "$utr"  == "TRUE" ]
		then
    			grep -P "\t(CDS|exon)\t" $gff | ~/.conda/envs/sqanti3_lrgasp/scripts/gtf2gff.pl --printIntron --out=tmp.gff
    			grep -P "\t(CDS|intron|exon)\t" tmp.gff > tmp2.gff
		# If the model was't trained to use UTR keep only the CDS
		else
    		grep -P "\t(CDS)\t" $gff | ~/.conda/envs/sqanti3_lrgasp/scripts/gtf2gff.pl --printIntron --out=tmp.gff
    		head tmp.gff
    		grep -P "\t(CDS|intron)\t" tmp.gff > tmp2.gff
		fi
		#rm tmp.gff

		# Remove gene_id and change transcript id for grp_id
		sed -i 's/gene_id[^;]*;//g' tmp2.gff
		sed -i 's/transcript_id \"/grp=/g' tmp2.gff

		# change the trancript id for the source
		cat tmp2.gff | sed 's/";/;pri=1;src=PB/g' > $name_file.hints.hits.gff
		#rm tmp2.gff

		if [ $part == "FALSE" ]
		then
			sed -i "s/exon/exonpart/g" $name_file.hints.hits.gff
			sed -i "s/intron/intronpart/g" $name_file.hints.hits.gff
			sed -i "s/CDS/CDSpart/g" $name_file.hints.hits.gff
		fi

		if [ $tmp_file == "TRUE" ]
		then
    			echo "no gff"
			#    rm $gff
		fi
		echo "-- FINISH GFT2HINTS --"
        fi
done

conda deactivate

module unload anaconda

date
