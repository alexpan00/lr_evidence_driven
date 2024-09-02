#!/bin/bash
#SBATCH --job-name=validate_ends
#SBATCH --output=validate_ends.out
#SBATCH --error=validate_ends.err
#SBATCH --time=1:00:00
#SBATCH --mem=16G
#SBATCH --cpus=8
#SBATCH --qos=short

module load blast
module load samtools


# Parse input arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --sqanti_class)
            sqanti_class="$2"
            shift
            ;;
        --protein_fasta)
            protein_fasta="$2"
            shift
            ;;
        --blast_db)
            blast_db="$2"
            shift
            ;;
        *)
            echo "Unknown option: $key"
            exit 1
            ;;
    esac
    shift
done


# Print the parsed input arguments
echo "sqanti_class: $sqanti_class"
echo "protein_fasta: $protein_fasta"
echo "blast_db: $blast_db"

mkdir -p outputs_$SLURM_JOB_ID

python 01_shoter_ends_TriMan.py -s $sqanti_class -o outputs_$SLURM_JOB_ID/shorter_ends.tsv

# extract the protein sequences of LRB trasncripts that extend TriMan 
# trasncripts ends
samtools faidx $protein_fasta -r <(cut -f2 outputs_$SLURM_JOB_ID/shorter_ends.tsv) > outputs_$SLURM_JOB_ID/full_sequences.fasta

# run blastp
blastp -query outputs_$SLURM_JOB_ID/full_sequences.fasta -db $blast_db \
    -evalue 1e-50 \
    -outfmt "6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore qlen slen" \
    -num_alignments 1 -num_threads 8 -out outputs_$SLURM_JOB_ID/blastp_results.tsv



