#!/bin/bash
# Wrapper of the script gff2Augustus.sbatch to initialize multiple jobs
# with different lenghts of the flanking region


# Check the args
if [ -z "$1" ] || [ $1 == '-h' ] || [ $1 == '--help' ]
then
    echo "Wrapper of the script gff2Augustus.sbatch to initialize multiple jobs"
    echo "with different lenghts of the flanking region."
    echo "Expected args:"
    echo -e "\tgff/gtf with the reliable genes"
    echo -e "\tgenome reference genome"
    echo -e "\tlength of the flanking regions separated with , (1000,2000)"
    echo -e "\tName for the species (model name) and output files"
    echo -e "\tSeed for the generation of random subsets"
    exit 0
fi

# Inputs
gff=$1      # gff/gtf with the reliable genes to train the model
genoma=$2   # reference genome
fr=$3       # length of the flanking region
out_dir=$4  # output dir
out_name=$5 # Name for the species and output files
seed=$6     # seed to generate subsets

# PATHS
utilities=$(dirname $(realpath -s $0))
species_path="/home/apadepe/.conda/envs/busco/config/species/"

# Create an array fwith the flanking region lengths
arrIN=(${fr//,/ })

# Create a common directory for all the results, then and individual dir will
# be created for the results of each length of the flanking region
mkdir $out_dir
cd $out_dir
# iterate over the different lengths of the flanking region
for i in "${arrIN[@]}"
do
    echo "Flanking region $i"
    # run the gtf2AUGUSTUS script
    sbatch --output AUGUSTUS_fr$i.log --job-name=AUGUSTUS_fr$i \
    ${utilities}/AUGUSTUS/gtf2Augustus.sbatch $gff $genoma \
    $i $out_dir/fr$i ${out_name}_fr$i
  
done        
