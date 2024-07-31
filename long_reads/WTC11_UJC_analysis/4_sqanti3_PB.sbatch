#!/bin/bash
#SBATCH --job-name=sqanti3_manatee_PB
#SBATCH --output=logs/sqanti3_PB_%A_%a.out 
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=15gb
#SBATCH --qos=short
#SBATCH --time=10:00:00
#SBATCH --array=0-49

pwd; date

# Script to run sqanti on PacBio flnc reads

# Define reference annotation, reference assembly 
ref_annotation="/home/apadepe/practicas/reference_human/lrgasp_gencode_v38_sirvs.gtf"
assembly="/home/apadepe/practicas/reference_human/lrgasp_grch38_sirvs.fasta"


# fofn of query gtf files
readarray -t myarray < PB_splitted.fofn


source activate sq3

# Read the file corresponding to the task
gff=${myarray[$SLURM_ARRAY_TASK_ID]}

dirname=$(dirname $gff)
sample=$(basename $gff ".gtf")

# Run SQANTI3
python3 /home/apadepe/lr_pipelines/SQANTI3/sqanti3_qc.py \
	--skipORF --dir SQANTI_PB/${sample} \
	--output ${sample} --min_ref_len "0" \
	--report "skip" \
	${gff} ${ref_annotation} ${assembly}

pwd;date
