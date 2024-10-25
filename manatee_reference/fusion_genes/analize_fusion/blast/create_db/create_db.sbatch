#!/bin/bash
#SBATCH --job-name=database_creation # Job name
#SBATCH --qos=short # Partition (queue)
#SBATCH --ntasks=1
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=5 # Number of tasks = cpus
#SBATCH --mem-per-cpu=8G # Job memory request
#SBATCH --time=1-00:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=create_blast_db_%j.log # Standard output and error log

# Script to create a custom database

# INPUTS
dir_db=$1 # DB directory
file=$2 # File
mode=$3 # Mode
name_db=$4 # Database name
name_out=$5 # Output name

# Check INPUTS
if [ -z "$1" ] || [ $1 == '-h' ] || [ -z "$2" ]
then
    echo "Arguments:"
    echo -e "\tDB directory"
    echo -e "\tFile"
    echo -e "\tMode"
    echo -e "\tDatabase name"
    echo -e "\tOutput name"
    exit 0
fi

echo "INPUTS:"
echo "DB directory: $dir_db"
echo "File: $file"
echo "Mode: $mode"
echo "Database name: $name_db"
echo "Output name: $name_out"

date;pwd

cd $dir_db

pwd

module purge && module load blast/2.13

makeblastdb -in $file -title $name_db -dbtype $mode -out $name_out

module unload blast/2.13

date
