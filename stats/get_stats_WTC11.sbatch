#!/bin/bash
#SBATCH --job-name=get_stats # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-08:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=Stats_%A-%a.log # Standard output and error log

source activate cgat
# PATHS
# check if script is started via SLURM or bash
# if with SLURM: there variable '$SLURM_JOB_ID' will exist
# `if [ -n $SLURM_JOB_ID ]` checks if $SLURM_JOB_ID is not an empty string
if [ -n $SLURM_JOB_ID ];  then
    # check the original location through scontrol and $SLURM_JOB_ID
    SCRIPT_PATH=$(scontrol show job ${SLURM_JOB_ID} | grep Command | cut -f2 -d"=" | cut -f1 -d" ")
    echo $SCRIPT_PATH
else
    # otherwise: started with bash. Get the real location.
    SCRIPT_PATH=$(realpath -s $0)
fi
anotacion="/home/apadepe/practicas/reference_human/new_chr19/filtered_modificado_chr19_CDS.gtf"
genoma="/home/apadepe/practicas/reference_human/chr19.fa"
ref_prot="/home/apadepe/practicas/reference_human/new_chr19/chr19_transcripts.faa"
utilities=$(dirname $SCRIPT_PATH)

# TO DO: get alternatives for running as array and as indiviual jobs
# Go to working directory
#wd=$(sed -n ${SLURM_ARRAY_TASK_ID}p $1)
cd $1
# Make an ouput folder for the results
mkdir cuffcompare_results
# Read the gtf files
for file in *.gtf
do
    arrIN=(${file//./ })
    # Compare to the reference
    echo "Comparing $file"
    date
    cuffcompare -e 0 -d 0 -T -o cuffcompare_results/${arrIN[0]} -r $anotacion $file
    # Generate de faa file from the AUGUSTUS gtf 
    date
    conda activate cgat
    echo "Generating protein sequences"
    agat_sp_extract_sequences.pl --gff $file -f $genoma -p \
        -o cuffcompare_results/${arrIN[0]}.faa > /dev/null
    sed -i 's/'*'//g' cuffcompare_results/${arrIN[0]}.faa
    # Generate the alignents
    conda activate SQANTI3.env
    echo "Aligning compatible proteins"
    date
    python ${utilities}/align.py cuffcompare_results/${arrIN[0]}.tracking \
        cuffcompare_results/${arrIN[0]}.faa $ref_prot \
        cuffcompare_results/${arrIN[0]}.identity
    echo "Alingment of sample $file finished"
    date
done 

# Generate the summary file
python ${utilities}/get_stats.py `pwd`/cuffcompare_results
