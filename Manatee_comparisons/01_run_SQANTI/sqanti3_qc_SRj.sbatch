#!/bin/bash
#SBATCH --job-name=sqanti_qc
#SBATCH --output=sqanti_qc_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=20G
#SBATCH --time=4-00:00:00
#SBATCH --qos=medium
#SBATCH --mail-type=ALL

export PYTHONPATH=$PYTHONPATH:/home/crisag/SQANTI3-5.2/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/home/crisag/SQANTI3-5.2/cDNA_Cupcake/

gtf_input=$1
gtf_reference=$2
genome=$3
out_dir=$4
out_name=$5
SJ_sr=$6

echo "Parámetros introducidos"
echo "  GTF de entrada: $gtf_input"
echo "  GTF de referencia: $gtf_reference"
echo "  Genoma: $genome"
echo "  Directorio salida: $out_dir"
echo "  Nombre output: $out_name"
echo "  Splice-junctions: $SJ_sr"

module purge && module load anaconda

conda activate SQANTI3.env

pwd ; date

echo "Run SQANTI:"

python /home/crisag/SQANTI3-5.2/sqanti3_qc.py $gtf_input $gtf_reference $genome \
       -c $SJ_sr -d $out_dir -o $out_name --skipORF --min_ref_len 0

conda deactivate
module unload anaconda

date
