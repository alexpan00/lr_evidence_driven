#!/bin/bash
#SBATCH --job-name=prepareBUSCO # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-24:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=prepare_busco.log # Standard output and error log

# Script to get a gtf of non-redundant BUSCO genes after running the BUSCO
# analysis on the genome

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
utilities=$(dirname $SCRIPT_PATH)


# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Script to get a gtf of non redundant BUSCOS"
    echo "Expected args:"
    echo -e "\tpath to the BUSCO complete genes sequences"
    echo -e "\tpath to the BUSCO complete genes in gtf format"
    echo -e "\toutput dir"
    exit 0
fi

# ARGS
busco_seqs=$1 
busco_gff=$2 
out_dir=$3 

source activate SQANTI3.env

# Get th sequences in fasta format of the BUSCO complete genes
python $utilities/busco_complete_aa.py $busco_seqs $out_dir

cd $out_dir
conda activate busco
# collpase the sequences with and identity higher than an 80%
cd-hit -o complete_buscos.cdhit -c 0.8 -i complete_buscos.faa -p 1 -d 0 -T 4 -M 48000
grep ">" complete_buscos.cdhit | cut -f2 -d">" | cut -f1 > cdhit.lst

# Concatenate the gff files of the non-collapsed genes
python $utilities/concatenateGFF.py cdhit.lst $busco_gff
