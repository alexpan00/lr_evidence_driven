#!/bin/bash
#SBATCH --job-name=SQANTI3 # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mem-per-cpu=8gb # Per processor memory
#SBATCH -t 00-12:00:00     # Walltime
#SBATCH --output=SQANTI3.log # Standard output and error log

# Example run of SQANTI3 
# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Example run of SQANTI3"
    echo "Expected args:"
    echo -e "\tIsoforms: path to the transcriptome"
    echo -e "\tAnnotation: path to the reference annotation file"
    echo -e "\tGenome: path to the reference genome"
    echo -e "\tOutput name: prefix for output files"
    echo -e "\tOutput dir: diirectory for output files"
    echo -e "\tSplice junctions: directory with the SJ.out.tab produced by STAR"
    echo -e "\tFL count: path to the abundance file"
    echo -e "SQANTI dir: path to the SQANTI directory"
    echo -e "cDNA cupcake dir: path to the cDNA cupcake directory"
fi

# ARGS
isoforms=$1
annotation=$2
genome=$3
out_name=$4
out_dir=$5
SJ=$6
FL=$6
sqanti_dir=$7
cDNA_dir=$8

source activate SQANTI3.env

# PATHS
export PYTHONPATH=$PYTHONPATH:$cDNA_dir/sequence/
export PYTHONPATH=$PYTHONPATH:$cDNA_dir

date;pwd
python $sqanti_dir/sqanti3_qc.py $isoforms $annotation $genome \
            -o $out_name -d $out_dir \
		    -c $SR --report both --fasta -t 4 \
            --force_id_ignore --fl_count $FL