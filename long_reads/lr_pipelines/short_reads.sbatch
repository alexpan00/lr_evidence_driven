#!/bin/bash
#SBATCH --job-name=short_reads # Job name
#SBATCH --partition=long # Partition (queue)
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mem-per-cpu=10gb # Per processor memory
#SBATCH -t 10-00:00:00     # Walltime
#SBATCH --output=isoseq.log # Standard output and error log

# Example map short read date and use the SJ in FLAIR and SQANTI3 
# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Pipeline to process paired-end short read data"
    echo "Expected args:"
    echo -e "\tPath to the genome"
    echo -e "\tPath to fofn. Each line must include the path to a paired-end"
    echo -e "\t\tsample without the extension that must be _r1_fastq.gz for"
    echo -e "\t\tthe forward read and r2_fastq.gz for the reverse"
    echo -e "\tPath to the outputs"
fi

# ARGS
genome=$1
fofn=$2
wd=$3

conda activate mapper

date; echo "Create the STAR index"
STAR --runThreadN 8 \
--runMode genomeGenerate \
--genomeDir $(dirname $genome)/index \
--genomeFastaFiles $genome 