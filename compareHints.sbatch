#!/bin/bash
#SBATCH --job-name=compare_hints # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-24:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=compare_hints.log # Standard output and error log

# Script to compare different sources of external evidence using the same model

# PATHS
utilities="/home/apadepe/utilities/"

# INPUTS
model=$1 # AUGUSTUS species to be use for the gene prediction
source_config=$2 # FOFN with the hints and the config file paths separated by ,
genome=$3 # Genome file
out_dir=$4 # Directory for the outputs

# Check INPUTS
if [ -z "$1" ] || [ $1 == '-h' ] || [ -z "$2" ]
then
    echo "Arguments:"
    echo -e "\tAGUSTUS species"
    echo -e "\tConfig file: FOFN with the hints and the config file paths separated by ,"
    echo -e "\t\tFOFN with the hints and the config file paths separated by ,"
    echo -e "\tGenome"
    echo -e "\tOutput directory"
    exit 0
fi

source activate busco
#mkdir $out_dir
# Read the configurarion file
while read -r line
do
    arrIN=(${line//,/ })
    hint=${arrIN[0]}
    cfg=${arrIN[1]}
    tec=${arrIN[2]}
    date
    echo "Using $hint as hints for the prediction"
    SOURCES=$(grep -n SOURCES $cfg | cut -f1 -d":" | head -n 1)
    SOURCES=$((SOURCES + 1))
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
sbatch ${utilities}get_stats_WTC11.sbatch $out_dir
echo "Finished"
date
