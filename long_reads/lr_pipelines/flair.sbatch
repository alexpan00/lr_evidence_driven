#!/bin/bash
#SBATCH --job-name=flair # Job name
#SBATCH --partition=long # Partition (queue)
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mem-per-cpu=10gb # Per processor memory
#SBATCH -t 10-00:00:00     # Walltime
#SBATCH --output=flair.log # Standard output and error log

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
    echo "Example run of the FLAIR pipeline"
    echo "Expected args:"
    echo -e "\tPath to fofn. Each line must include the path to a fastq.gz"
    echo -e "\t\twithout the fastq.gz extension"
    echo -e "\tPath to the genome"
    echo -e "\tPath to the write the outputs"
    echo -e "\tPath to FLAIR direcotry"
fi

# ARGS
wd=$3 
fofn=$1
genome=$2
flair=$4

source activate flair_env

date
date ; echo "Aligning the reads to the genome"
while read -r line
do
    date ; echo "Aligning `basename $line`"
    file=$(basename $line)
    python ${flair}/flair.py align -o ${wd}/${file}_aligned -t 12 -v1.3 \
        -r ${line}.fastq.gz -g $genome
done < $fofn

cd $wd
# FLAIR uses short reads information. The information about how to process the
# short reads data can be found in the short_reads.sbatch script
date ; echo "Correct the splice sites using short reads information."
while read -r line
do
    date ; echo "Correct `basename $line`"
    sample=$(basename $line)
    python ${flair}/flair.py correct -o ${sample}_corrected -t 12 \
        -q ${sample}_aligned.bed -g $genome -j $SJ --print_check
done < $fofn


echo "Concatenate all the samples in complete.bed"
cat *corrected.bed > complete.bed
date ; echo "Collapse"
reads_path=$(head -1 $fofn)
reads_path=$(dirname $read_path)
python ${flair}flair.py collapse -o FLAIR -s 2 -t 12 --stringent \
    --check_splice -q complete.bed -g $genome \
    --filter nosubset --generate_map \
    -r ${reads_path}/*.fast.gz

echo "Count the number of reads associated to each transcript and give the"
echo "transcripts a simpler name"
date
python $utilities/FLAIR/count_rename.py FLAIR `pwd`