#!/bin/bash
#SBATCH --job-name=get_stats # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-08:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=Stats.log # Standard output and error log

# PATHS
anotacion="/home/apadepe/practicas/reference_human/chr19_CDS_LO.gtf"

# Ir al directorio de trabajo
cd $1
mkdir cuffcompare_results
for file in *.gtf
do
   arrIN=(${file//./ })
   cuffcompare -e 0 -d 0 -o cuffcompare_results/${arrIN[0]} -r $anotacion $file
done 

cd cuffcompare_results
echo -e "N_genes"'\t'"nt_sn"'\t'"nt_sp"'\t'"exon_sn"'\t'"exon_sp"'\t'"gene_sn"'\t'"gene_sp" > summary.tsv

for file in *.stat
do
    N_genes=$(echo $file | cut -f1 -d"." | cut -f2 -d"_")

    nt_sn=$(grep Base $file | cut -f 2 | cut -f2 -d " ")
    nt_sp=$(grep Base $file | cut -f 3 | cut -f2 -d " ")

    exon_sn=$(grep Exon $file | cut -f 2 | cut -f2 -d " ")
    exon_sp=$(grep Exon $file | cut -f 3 | cut -f2 -d " ")
    gene_sn=$(grep Transcript $file | cut -f 2 | cut -f2 -d " ")
    gene_sp=$(grep Transcript $file | cut -f 3 | cut -f2 -d " ")
    echo -e "$N_genes"'\t'"$nt_sn"'\t'"$nt_sp"'\t'"$exon_sn"'\t'"$exon_sp"'\t'"$gene_sn"'\t'"$gene_sp" >> summary.tsv
done
