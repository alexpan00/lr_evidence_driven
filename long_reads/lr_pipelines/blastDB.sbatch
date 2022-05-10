#!/bin/bash
#SBATCH --job-name=blastDB # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mem-per-cpu=8gb # Per processor memory
#SBATCH -t 01-00:00:00     # Walltime
#SBATCH --output=blastDB.log # Standard output and error log

# PATH
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

utilities=$(dirname $(dirname $(dirname $SCRIPT_PATH)))

date;pwd
# Example run of FLIAR pipeline 
# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Example script to batch download from Uniprot and creation of a blast data base"
    echo "Expected args:"
    echo -e "\tLink to download the desire proteome from Uniprot"
    echo -e "\tOutput folder for the blastDB"
    echo -e "\tName for the blastDB"
fi

# ARGS
link=$1
wd=$2
out_name=$3

source activate busco


date ; echo "Downloading protein sequences:"
wget -O $wd/$out_name.faa -q "$link"

date ; echo "Creating blast database"
makeblastdb -in $wd/$out_name.faa -title $out_name -dbtype prot -out pdbaa -parse_seqids