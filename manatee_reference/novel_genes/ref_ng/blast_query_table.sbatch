#!/bin/bash
#SBATCH --job-name=blast_query # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=5 # Number of tasks = cpus
#SBATCH --mem-per-cpu=2G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=blast_query_%j.log # Standard output and error log

# Script to run blast

# INPUTS
file=$1 # Protein FASTA file
db=$2 # Database
out_file=$3 # Output name

# Check INPUTS
if [ -z "$1" ] || [ $1 == '-h' ] || [ -z "$2" ]
then
    echo "Arguments:"
    echo -e "\tProtein FASTA file"
    echo -e "\tDatabase"
    echo -e "\tOutput name"
    exit 0
fi

echo "INPUTS:"
echo "Protein FASTA file: $file"
echo "Database: $db"
echo "Output name: $out_file"

date;pwd

module purge && module load blast/2.13

blastp -query $file -db $db -out $out_file -outfmt 6 -num_alignments 1 -evalue 1e-3

date

module unload blast/2.13
