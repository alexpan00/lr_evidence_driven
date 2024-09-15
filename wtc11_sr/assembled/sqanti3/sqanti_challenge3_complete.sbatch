#!/bin/bash
#SBATCH --job-name=sqanti_complete
#SBATCH --output=sqanti_wtc11_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=60G
#SBATCH --time=3-00:00:00
#SBATCH --qos=medium
#SBATCH --mail-type=ALL

export PYTHONPATH=$PYTHONPATH:/home/crisag/SQANTI3-5.1.1/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/home/crisag/SQANTI3-5.1.1/cDNA_Cupcake/

#NOTE:In this case, the reference GTF does not matter, as the filtering process for generating hints doesn't use SQANTI3 cathegories.

module purge && module load anaconda

conda activate sqanti3_lrgasp

pwd ; date

#Run SQANTI:

echo "Run SQANTI"

python /home/crisag/lrgasp-challenge-3-evaluation/sqanti3_lrgasp.challenge3.py --gtf /home/crisag/muestras_wtc11_sr/protocol2_sr_assembled/stringtie/muestras_wtc11_sr_merged_new.gtf \
        /storage/gge/Alejandro/reference_manatee/lrgasp_sirvs4.gtf \
        /storage/gge/Alejandro/WTC11/lrgasp_grch38_sirvs.fasta \
	--experiment_json /home/crisag/lrgasp-challenge-3-evaluation/utilities/experiment_dummy.json --entry_json /home/crisag/lrgasp-challenge-3-evaluation/utilities/entry_dummy.json \
	-d /home/crisag/muestras_wtc11_sr/protocol2_sr_assembled/sqanti/output_sqanti -o wtc11_sr_sqanti

module unload anaconda

date
