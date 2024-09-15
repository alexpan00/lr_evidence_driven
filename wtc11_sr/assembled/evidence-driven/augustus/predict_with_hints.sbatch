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

# INPUTS
model=$1 # AUGUSTUS species to be use for the gene prediction
cfg=$2 # path to the config file
genome=$3 # Genome file
hints=$4 # Path to the hints file
out_dir=$5 # Directory for the outputs

# Check INPUTS
if [ -z "$1" ] || [ $1 == '-h' ] || [ -z "$2" ]
then
    echo "Arguments:"
    echo -e "\tAUGUSTUS species"
    echo -e "\tConfig file"
    echo -e "\tGenome"
    echo -e "\tPath to the hints file"
    echo -e "\tOutput directory"
    exit 0
fi

echo "Species: $model"
echo "Config file: $cfg"
echo "Genome: $genome"
echo "hints: $hints"
echo "Output dir: $out_dir"
date;pwd

module purge && module load anaconda
conda activate sqanti3_lrgasp

#mkdir $out_dir
cd $out_dir

augustus --species=$model --extrinsicCfgFile=$cfg --hintsfile=$hints \
    $genome --softmasking=on > \
    $out_dir/wtc11_sr_filtered.gtf

date

module unload anaconda
