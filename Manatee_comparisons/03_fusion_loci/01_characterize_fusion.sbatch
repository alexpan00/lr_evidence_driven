#!/bin/bash
#SBATCH --job-name=validate_ends
#SBATCH --output=validate_ends.out
#SBATCH --error=validate_ends.err
#SBATCH --time=1:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --qos=short

mkdir -p outputs_$SLURM_JOB_ID

class=$1 # Sqsnti output from hints vs transcripts

# Group the hints by loci and get a loci transcript association file
gffread -T --cluster-only manatee_gge_hints_busco_sqanti_corrected.gtf | cut -d '"' -f2,6 | grep RLOC | cut -d'"' -f1-2 --output-delimiter=$'\t' > "outputs_$SLURM_JOB_ID/transcript_loci.tsv"

Rscript 02_fusion.R $class outputs_$SLURM_JOB_ID/transcript_loci.tsv