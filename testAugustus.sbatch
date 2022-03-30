#!/bin/bash
#SBATCH --job-name=test_isoseq # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-02:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=isoseq_test.log # Standard output and error log

source activate busco
# PATH
utilities="/home/apadepe/utilities/"

# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Script to run AUGUSTUS give a species and test file"
    echo "Expected args:"
    echo -e "\tspecies: model to be used by AUGUSTUS"
    echo -e "\ttetst file: GeneBank or fatsa file for which the genes will be predicted"
    echo -e "\toutput dir (will be created)"
    exit 0
fi

# Args
species=$1
test_file=$2
out_dir=$3

augustus --species=$species ${test_file} > $out_dir/$species.out
