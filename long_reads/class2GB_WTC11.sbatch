#!/bin/bash
#SBATCH --job-name=class2GB # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=8 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-24:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=class2GB.log # Standard output and error log

# Script that goes from the classsification output produced using
# SQANTI3 to the final gtf with filtered non redundant trasncripts


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

export PYTHONPATH=$PYTHONPATH:/home/apadepe/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/home/apadepe/cDNA_Cupcake/
utilities=$(dirname $(dirname $SCRIPT_PATH))
tama_dir="/home/apadepe/lr_pipelines/tama/"
genoma="/home/apadepe/practicas/reference_human/lrgasp_grch38_sirvs.fasta"
anotacion="/home/apadepe/practicas/reference_human/lrgasp_gencode_v38_sirvs.gtf"
SR="/storage/gge/Alejandro/WTC11/Illumina/trimmed/SJ/"
SQ_utilities="/home/apadepe/lr_pipelines/sqanti_versions/lrgasp-challenge-3-evaluation/utilities/"
SQ_folder="/home/apadepe/lr_pipelines/sqanti_versions/lrgasp-challenge-3-evaluation/"
BUSCO_dir="/home/apadepe/TFM/BUSCO/busco_downloads"
BLAST_DB="/storage/gge/Alejandro/mammalian_proteins/blastDB/mammalian"

# TO DO: rm the files that are not going to be used. Plot the BUSCO completness
# of every step
# check the inputs
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Script that goes from the classsification output produced using"
    echo "SQANTI3 to the final gtf with filtered non redundant trasncripts."
    echo "Expected inputs:"
    echo -e "\tpath to the SQANTI3 outputs"
    echo -e "\tSQANTI3 outputs prefix"
    echo -e "\toutput dir path where the outputs will be save"
    echo -e "\tsequencing tecnology that was used to build the trancriptome (PB/ONT)"
    exit 0
fi

# ARGS
sqanti_output_dir=$1 # Path of the SQANTI3 outputs
sqanti_prefix=$2 # Prefix of the SQANTI3 outputs
out_dir=$3 # output dir for the results
tec=$4 # tecnology used to to sequence the trasncripts

# Filtering the classification file
echo "Filtering of the classification file:"
source activate busco

# One of the things that is checked to filter the classification is that the
# transcript has blast hits in the mammalian reference proteome with a query
# coverage of at least an 80%
echo "BLAST against the reference mamalian proteome:"
date
blastp -query $sqanti_output_dir/*.faa -db $BLAST_DB -out $out_dir/blastp_out.txt \
    -evalue 1e-50 \
    -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen" \
    -num_alignments 3 -num_threads 8 
date
conda activate lrgasp2
# Use the short read coverage, the blast information and other parameters 
# calculated by SQANTI3 to filter the transcriptome
echo "Using BLAST info and SR to filter the clasification"
Rscript $utilities/filters/filterClassification.R $sqanti_output_dir $sqanti_prefix $out_dir \
    $out_dir/blastp_out.txt $tec

# Filtering the sam file from the trasncripts mapping using the filtered
# classification
echo "Filter and order the sam file:"
python $utilities/filters/filter_sam.py ${out_dir}/filtered_${sqanti_prefix}_classification.txt \
    ${sqanti_output_dir}/${sqanti_prefix}_corrected.sam $out_dir

# Use the sam file to collapse the trasncripts using tama
cd $out_dir
# Sorting
samtools sort -u -o sorted_${sqanti_prefix}.sam -O sam -@ 4 filtered_${sqanti_prefix}_corrected.sam

# TAMA collapse
conda activate tama
echo "Collapse at isoform level:"
python ${tama_dir}tama_collapse.py -s ${out_dir}/sorted_${sqanti_prefix}.sam -f $genoma\
    -p $out_dir/${sqanti_prefix} -x no_cap -m 100 -z 100

conda activate lrgasp2
# Convert to GTF
python ${utilities}/long_reads/bed2gtf.py ${sqanti_prefix}.bed

# Run SQANTI3 on the filtered GTF
mkdir ${out_dir}/SQANTI3
cd $SQ_folder
echo "Running SQANTI3 on the collapsed isoforms:"
python sqanti3_lrgasp.challenge3.py ${out_dir}/${sqanti_prefix}.gtf $anotacion $genoma \
	--experiment_json ${SQ_utilities}experiment_dummy.json \
    --entry_json ${SQ_utilities}entry_dummy.json \
	-c $SR -d ${out_dir}/SQANTI3 \
	-o $sqanti_prefix -t 8 -g --skip_report

cd $out_dir

# Collapse using the protein aligment. Collapseing the proteins with an
# identity higher than an 80%
conda activate busco

echo "Collapse at protein level:"
cd-hit -o ${sqanti_prefix}.cdhit -c 0.8 -i SQANTI3/${sqanti_prefix}_corrected.faa -p 1 -d 0 -T 4 -M 48000

# Check redundancy after collapse
echo "BUSCO anlysis post-colapse:"
busco -m protein -i ${sqanti_prefix}.cdhit -o busco_cdhit -l eutheria_odb10 \
    -c 4 --offline --download_path $BUSCO_dir

# Get the id from the slectected transccripts
echo "Final filtering"
grep ">" ${sqanti_prefix}.cdhit | cut -f2 -d">" | cut -f1 > cdhit.lst 

# Filter the GTF to keep the selected trasncripts
python ${utilities}/filters/filter_gtf.py ${out_dir}/cdhit.lst \
    ${out_dir}/SQANTI3/${sqanti_prefix}_corrected.gtf.cds.gff \
    ${out_dir}

mkdir AUGUSTUS
