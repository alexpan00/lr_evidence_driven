#!/bin/bash
#SBATCH --job-name=short_reads # Job name
#SBATCH --partition=long # Partition (queue)
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mem-per-cpu=10gb # Per processor memory
#SBATCH -t 10-00:00:00     # Walltime
#SBATCH --output=isoseq.log # Standard output and error log


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
    echo -e "\tPath to the output directory"
fi

# ARGS
genome=$1
fofn=$2
wd=$3

# Reads sufix
p1="_r1.fastq.gz"
p2="_r2.fastq.gz"

conda activate mapper

date; echo "Creating the STAR index"
STAR --runThreadN 8 \
--runMode genomeGenerate \
--genomeDir $(dirname $genome)/index \
--genomeFastaFiles $genome 

# Make a new folder to store the trimmed short reads
mkdir $wd/trimmed

# Make a folder to store the SJ data
mkdir $wd/trimmed/SJ

while read -r line
do
	date
	echo "Trimming adaptors from sample $line"
    sample=$(basename $line)
	mkdir $wd/trimmed/$sample
    # fastp provides QC and triming of the adaptors of the reads
	fastp --detect_adapter_for_pe \
        --correction --cut_right --thread 12 \
        --html trimmed/$sample/out_${sample}.html \
        --json trimmed/$sampe/out_${sample}.json \
        -i $line$p1 -I $line$p2 \
        -o trimmed/$sample/$sample$p1 -O trimmed/$sample/$sample$p2

	mkdir trimmed/$sampe/map_out
	date
	echo "Mapping $line"
	STAR --runThreadN 12 --genomeDir $genome/index \
	--readFilesIn trimmed/$sampe/$sampe$p1 trimmed/$sampe/$sampe$p2 \
    --outFileNamePrefix trimmed/$sampe/map_out/$sampe \
	--alignSJoverhangMin 8  --alignSJDBoverhangMin 1 --outFilterType BySJout \
	--outSAMunmapped Within --outFilterMultimapNmax 20 \
	--outFilterMismatchNoverLmax 0.04 --outFilterMismatchNmax 999 \
	--alignIntronMin 20 --alignIntronMax 1000000 \
	--alignMatesGapMax 1000000 --sjdbScore 1 --genomeLoad NoSharedMemory \
	--outSAMtype BAM SortedByCoordinate --twopassMode Basic \
	--readFilesCommand zcat

    mv trimmed/$sampe/map_out/*SJ.out.tab $wd/trimmed/SJ
done < $fof

# For the FLAIR pipeline it is need to filter and concatenate all the short
# read data
date
echo "Prepare SJ for FLAIR"
# Concatenate all the SJ files produces by STAR
cat *SJ.out.tab > completeSJ.out.tab

# Filter based on the recomendations made by FLAIR developers, keep only the
# junctions with 2 reads supporting them.
awk '{ if ($7 > 2) { print } }' completeSJ.out.tab > filtered_completeSJ.out.tab
# Sort the SJ file
bedtools sort -i filtered_compelteSJ.out.tab > sorted_completeSJ.out.tab
# Sum the reads supportig the same SJ in different samples
python3 ${utilities}/FLAIR/collapseSJ.py `pwd`/sorted_completeSJ.out.tab

echo "Done. Run FLAIR using the SJ in collapsed_sorted_completeSJ.out.tab"


