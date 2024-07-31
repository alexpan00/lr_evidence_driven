#!/bin/bash
#SBATCH --job-name=compare_hints # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=10gb # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=compare_hints.log # Standard output and error log

# Script to compare different sources of external evidence using the same model

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

utilities=$(dirname $(dirname $SCRIPT_PATH))

# INPUTS
model=$1 # AUGUSTUS species to be use for the gene prediction
source_config=$2 # FOFN with the hints and the config file paths separated by ,
genome=$3 # Genome file
out_dir=$4 # Directory for the outputs

# Check INPUTS
if [ -z "$1" ] || [ $1 == '-h' ] || [ -z "$2" ]
then
    echo "Arguments:"
    echo -e "\tAUGUSTUS species"
    echo -e "\tConfig file: FOFN with the hints and the config file paths separated by ,"
    echo -e "\t\tFOFN with the hints paths, the config file paths and the tecnology separated by ,"
    echo -e "\tGenome"
    echo -e "\tOutput directory"
    exit 0
fi

source activate busco
mkdir $out_dir
cd $out_dir

# Read the configurarion file
while read -r line
do
    arrIN=(${line//,/ })
    hint=${arrIN[0]}
    cfg=${arrIN[1]}
    tec=${arrIN[2]}
    date
    echo "Using $hint as hints for the prediction"
    # Get the line of the file thath indicates the sources
    SOURCES=$(grep -n SOURCES $cfg | cut -f1 -d":" | head -n 1)
    SOURCES=$((SOURCES + 1))
    # Generate a concatenation of the sources
    sources_str=$(sed -n ${SOURCES}p $cfg | sed 's/ /+/g')
    # Start the prediction
    augustus --species=$model --extrinsicCfgFile=$cfg --hintsfile=$hint \
    $genome --protein=off --softmasking=off > \
    $out_dir/hints_${tec}_${sources_str}_${model}.gtf
    echo "Prediction finished"
    date
done < $source_config

conda activate base
echo "All predictions finished. Geting stats"
date
# Get the stats for all the predictions
sbatch ${utilities}/stats/get_stats_WTC11.sbatch $out_dir
echo "Finished"
date
