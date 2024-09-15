#!/bin/bash
#SBATCH --job-name=predict_with_hints # Job name
#SBATCH --qos=medium # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=7-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=predict_with_hints_%j.log # Standard output and error log

# Script to predict using hints

# PATHS
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

# INPUTS INVARIABLES
model=$1 # AUGUSTUS species to be use for the gene prediction
cfg=$2 # path to the config file
genome=$3 # Genome file
dir_hints_output=$4 #Directory of the hints files
main_dir=$(pwd | cut -d "/" -f 1-6) #Directorio principal

# Check INPUTS
if [ -z "$1" ] || [ $1 == '-h' ] || [ -z "$2" ]
then
    echo "Arguments:"
    echo -e "\tAUGUSTUS species"
    echo -e "\tConfig file"
    echo -e "\tGenome"
    echo -e "\tPath to the hints dir"
    exit 0
fi


echo "-- INVARIABLE INPUTS --"
echo "  Species: $model"
echo "  Configuration file: $cfg"
echo "  Genome: $genome"
echo "  Hints directory: $dir_hints_output"
echo "  Main directory: $main_dir"

date;pwd

module purge && module load anaconda
conda activate sqanti3_lrgasp

for dir in "$dir_hints_output"/*; do
	if [ -d "$dir" ]; then
		name_file=$(echo $dir | cut -d "/" -f 8 | cut -d "." -f1)
		if [ "$name_file" == 0 ] ; then
			name=$(echo $dir | cut -d "/" -f 8 | cut -d "." -f2)
			name_file="0.$name"
		fi
		hints=$dir/${name_file}.hints.hits.gff
		out_dir="$main_dir/output_augustus/$name_file"
		echo "-- VARIABLE INPUTS: --"
		echo "  Hints' output directory: $dir"
		echo "  Hints' file used: $hints"
		echo "  Output name: $name_file.augustus"
		echo "  Output directory: $out_dir"
		echo " Creating a directory with the name: $out_dir"
		mkdir $out_dir
		cd $out_dir
		echo "-- RUN AUGUSTUS--"
		augustus --species=$model --extrinsicCfgFile=$cfg --hintsfile=$hints $genome --softmasking=on > $out_dir/$name_file.augustus.gtf
		echo "-- FINISH AUGUSTUS--"
        fi
done

conda deactivate

module unload anaconda

date
