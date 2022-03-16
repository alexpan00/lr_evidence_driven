#!/bin/bash
#SBATCH --job-name=get_stats # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-08:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=Stats.log # Standard output and error log

source activate cgat
# PATHS
anotacion="/home/apadepe/practicas/reference_human/modificado_chr19_CDS_LO.gtf"
genoma="/home/apadepe/practicas/reference_human/chr19.fa"
ref_prot="/home/apadepe/practicas/reference_human/chr19_transcripts.faa"
utilities="/home/apadepe/utilities/"

# Go to working directory
cd $1
# Make an ouput folder for the results
mkdir cuffcompare_results
# Read the gtf files
for file in *.gtf
do
    arrIN=(${file//./ })
    # Compare to the reference
    cuffcompare -e 0 -d 0 -T -o cuffcompare_results/${arrIN[0]} -r $anotacion $file
    # Generate de faa file from the AUGUSTUS gtf 
    conda activate cgat
    agat_sp_extract_sequences.pl --gff $file -f $genoma -p \
        -o cuffcompare_results/${arrIN[0]}.faa > chapa.txt
    sed -i 's/'*'//g' cuffcompare_results/${arrIN[0]}.faa
    # Generate the alignents
    conda activate SQANTI3.env
    python ${utilities}align.py cuffcompare_results/${arrIN[0]}.tracking \
        cuffcompare_results/${arrIN[0]}.faa $ref_prot \
        cuffcompare_results/${arrIN[0]}.identity
   
done 

# Generate the summary file
python ${utilities}get_stats.py `pwd`/cuffcompare_results
