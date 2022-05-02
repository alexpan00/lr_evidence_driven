#!/bin/bash
#SBATCH --job-name=isoseq # Job name
#SBATCH --partition=long # Partition (queue)
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mem-per-cpu=10gb # Per processor memory
#SBATCH -t 10-00:00:00     # Walltime
#SBATCH --output=isoseq.log # Standard output and error log

date;pwd
# Example run of the isoseq3 pipeline 
# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Example run of the Isoseq3 pipeline"
    echo "Expected args:"
    echo -e "\tpath to the subreads"
    echo -e "\tpath to the primers fasta file"
    echo -e "\tpath to the genome"
fi

# ARGS
wd=$1 
primers=$2
genome=$3

source activate isoseq3
cd $wd
mkdir ccs
echo "Obtaining the consensus circular sequence, this may take a LONG time"
for file in *.bam
do
    filename="${file%.*}"
    ccs $file ccs/$filename.ccs.bam --report-file ccs/$filename.txt
done

cd css
echo "Running lima: removing primers"
for file in *.bam;
do
    echo $file
    filename="${file%.*}"
    lima --dump-clips --isoseq $file $primers $filename.fl.bam
done

echo "Creating a dataset to process all the reads together"
dataset create --type ConsensusReadSet combined_demux.consensusreadset.xml *.fl.Clontech_5p--Clontech_3p.bam

echo "Removing polyA tails"
echo "The output of this step (flnc.bam) will be the input for the FLAIR pipeline"
isoseq3 refine --require-polya combined_demux.consensusreadset.xml $primers flnc.bam

echo "Clustering the FLNC reads"
isoseq3 cluster flnc.bam polished.bam --verbose --use-qvs

echo "Map the clustered reads to the genome"
minimap2 -ax splice -t 12 -uf --secondary=no -C5 \
   $genome polished.hq.fasta.gz > hq_isoforms.fastq.sam

echo "Cluster transcripts using the mapping information"
gunzip polished.hq.fasta.gz
# Order the sam file
sort -k 3,3 -k 4,4n hq_isoforms.fastq.sam > hq_isoforms.fastq.sorted.sam
collapse_isoforms_by_sam.py --input polished.hq.fasta \
   -s hq_isoforms.fastq.sorted.sam  -o WTC11

echo "Count the number of reads associated to each transcript"
get_abundance_post_collapse.py WTC11.collapsed polished.cluster_report.csv

echo "Filter the transcripts based on the number of associated reads"
filter_by_count.py --dun_use_group_count WTC11.collapsed