#!/bin/bash
#SBATCH --job-name=collapseSJ # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-02:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=sortSJ.log # Standard output and error log

source activate flair_env

# Script to collpase identical SJ between sampels found using STAR and get the
# total number of supporting readsAR

# PATHS
# check if script is started via SLURM or bash
# if with SLURM: there variable '$SLURM_JOB_ID' will exist
# `if [ -n $SLURM_JOB_ID ]` checks if $SLURM_JOB_ID is not an empty string
if [ -n "$SLURM_JOB_ID" ];  then
    # check the original location through scontrol and $SLURM_JOB_ID
    SCRIPT_PATH=$(scontrol show job ${SLURM_JOB_ID} | grep Command | cut -f2 -d"=" | cut -f1 -d" ")
    echo $SCRIPT_PATH
else
    # otherwise: started with bash. Get the real location.
    SCRIPT_PATH=$(realpath -s $0)
fi

export PYTHONPATH=$PYTHONPATH:/home/apadepe/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/home/apadepe/cDNA_Cupcake/
utilities=$(dirname $SCRIPT_PATH)

# Args
in_dir=$1

# Go to working directory
cd $in_dir

# Combine all the SJ files
cat *SJ.out.tab > compelteSJ.out.tab

# Order the file
bedtools sort -i compelteSJ.out.tab > sorted_completeSJ.out.tab
rm compelteSJ.out.tab

# Collapse the splice junctions and sum the coverage
python3 ${utilities}collapseSJ.py $in_dir/sorted_completeSJ.out.tab
