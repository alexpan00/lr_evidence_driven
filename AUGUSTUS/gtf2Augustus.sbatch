#!/bin/bash
#SBATCH --job-name=fr_1000 # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-12:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=Augustus_subsets.log # Standard output and error log

# Script to run AUGUSTUS from a gtf/gff file using different sizes for the
# training set, length of the flanking regions and generate plots from the
# results.

# This script is focused in testing how the number of genes of the training 
# sets, the length of the flanking region and the different data used to
# train the model affect the results. The predictions are run on a subset of
# the genes used for training to evaleute the different models.

# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Script to run AUGUSTUS from a gtf/gff file using different sizes"
    echo "for the training set, length of the flanking regions and generate"
    echo "plots from the results"
    echo "Expected args:"
    echo -e "\tgtf/gff"
    echo -e "\tgenome"
    echo -e "\tlength of the flanking region"
    echo -e "\toutput dir (will be created)"
    echo -e "\tname for the output files"
    echo -e "\tseed to generate random subsets (default = 123)"
    exit 0
fi

pwd;date
# module load conda
source activate busco

# PATH
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

utilities=$(dirname $(dirname $SCRIPT_PATH))

# Inputs
gff=$1      # gff/gtf with the reliable genes to train the model
genoma=$2   # reference genome
fr=$3       # length of the flanking region
out_dir=$4  # output dir
out_name=$5 # Name for the species and output files
seed=$6     # seed to generate subsets


# Run info
echo "Run info: "
echo "Genome: $genoma"
echo "GTF/GFF: $gff"
echo "Length of the flanking region: $fr"
echo "Output dir: $out_dir"
echo "Name for the outputs: $out_name"
if [ -z "$6" ]
then
    echo "Semilla: 123"
else
    echo "Semilla: $seed"
fi

# Create the outputs dir
mkdir $out_dir

# From gtf to genebank format adding the flanking regions
echo "Create the file in GeneBank format"
gff2gbSmallDNA.pl $gff $genoma $fr $out_dir/$out_name.gb

# Generate the training and testing sets
cd $out_dir
mkdir results
echo "Generate the training and testing sets:"
randomSplit.pl $out_name.gb 500
mv $out_name.gb.test results/${out_name}_test.gb
mv $out_name.gb.train ${out_name}_train.gb

# Generate the subsets for training
echo "Generate the training subsets:"

# Get subset sizes
subsets=$(python3 ${utilities}/AUGUSTUS/autosubsets.py `grep -c LOCUS ${out_name}_train.gb`)

echo "Subsets sizes: $subsets"
python3 ${utilities}/AUGUSTUS/generate_subsets.py ${out_name}_train.gb $out_name `pwd`/\
    -l $subsets --seed $seed
cd results

echo "Train the models using the subsets:"
echo "Initial training and filtering of wrongly defined genes"
date
# Script to generate a new species in AUGUSTUS
for file in *.gb
do
    echo $file
    arrIN=(${file//./ })
    new_species.pl --species=${arrIN[0]}
    # First estraining run, will be used to check if stop codons are part of
    # the CDS
    etraining --species=${arrIN[0]} $file &> ${arrIN[0]}_etrain.out

    # Check if the Stop codon is missing in the genes
    echo "NO stop codon:"
    grep -c "Variable stopCodonExcludedFromCDS set right" ${arrIN[0]}_etrain.out

    # Remove the genes missing the stop codon, generate a lsit with the genes
    # to be removed
    grep "in sequence" ${arrIN[0]}_etrain.out | cut -f7 -d" " | sed s/://g | sort -u > ${arrIN[0]}_bad.lst

    # Use the lsit to filter the GeneBank file
    filterGenes.pl ${arrIN[0]}_bad.lst $file > ${arrIN[0]}.f.gb
done
date

# Once the initial files are filtered the model is trainned again and tested
echo "Testing of the models"
for file in subset*.f.gb
do
    echo $file
    date
    arrIN=(${file//./ })
    # Retrain the model with the filtered genes
    etraining --species=${arrIN[0]} $file &> ${arrIN[0]}_etrain.f.out
    # Frequency of the different stop codons
    tail -6 ${arrIN[0]}_etrain.f.out | head -3 > ${arrIN[0]}_SC_freq.txt
    # Adjsut the frecuency in the configuration file
    python3 ${utilities}/AUGUSTUS/modify_SC_freq.py ${arrIN[0]}_SC_freq.txt ${arrIN[0]}
    # Run AUGUSTUS using the model 
    augustus --species=${arrIN[0]} ${out_name}_test.f.gb > ${arrIN[0]}.out
    date
done
date
mkdir filtered_subsets/
mv *.f.gb filtered_subsets/
mv *.lst filtered_subsets/
mkdir SC_freq
mv *.txt SC_freq/
mkdir subsets
mv *.gb subsets/
mkdir first_train
mkdir second_train
mv *.f.out second_train/
mv *etrain.out first_train/
echo "Generate summary and plots"
bash ${utilities}/stats/get_stats.sh `pwd`
Rscript ${utilities}/AUGUSTUS/plots.R `pwd` $out_name
