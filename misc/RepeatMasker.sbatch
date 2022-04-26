#!/bin/bash
#SBATCH --job-name=RepeatMasker # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=8 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8gb # Job memory request
#SBATCH --time=0-24:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=mask_genome.log # Standard output and error log

# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Script to soft-mask a mammalian genome using basic options"
    echo "Expected args:"
    echo -e "\tpath to the genome"
    exit 0
fi

# ARGS
genome=$1 

# Arguments used to call RepeatMasker:
# -pa number of sequence batch jobs (use half of the core number)
# -nolow don't mask low complexity regions (recomended for genome anotation)
# -species the repetion database to be used
# -no_is skip bactrial insertion cheking
# -xsmall soft-mask intead of hard-mask
RepeatMasker -pa 4 -nolow -species Mammalia -no_is -xsmall -html $genome