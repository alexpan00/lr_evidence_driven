#!/bin/bash
#SBATCH --job-name=class2GB # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=4 # Number of tasks = cpus
#SBATCH --mem-per-cpu=12gb # Job memory request
#SBATCH --time=0-24:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=class2GB.log # Standard output and error log

# Script que permite ir desde el arhivo classification de salida de
# SQANTI3 hasta los tránscritos filtrados y colapsados en formato GB

source activate lrgasp2
# PATHS
export PYTHONPATH=$PYTHONPATH:/home/apadepe/cDNA_Cupcake/sequence/
export PYTHONPATH=$PYTHONPATH:/home/apadepe/cDNA_Cupcake/
utilities="/home/apadepe/utilities"
tama_dir="/home/apadepe/lr_pipelines/tama/"
genoma="/home/apadepe/practicas/reference_human/lrgasp_grch38_sirvs.fasta"
anotacion="/home/apadepe/practicas/reference_human/lrgasp_gencode_v38_sirvs.gtf"
SR="/storage/gge/Alejandro/WTC11/Illumina/trimmed/SJ/"
SQ_utilities="/home/apadepe/lr_pipelines/sqanti_versions/lrgasp-challenge-3-evaluation/utilities/"
SQ_folder="/home/apadepe/lr_pipelines/sqanti_versions/lrgasp-challenge-3-evaluation/"
BUSCO_dir="/home/apadepe/TFM/BUSCO/busco_downloads"

# ARGS
sqanti_output_dir=$1 # Directorio de salida de los output de SQANTI3
sqanti_prefix=$2 # Prefijo de los output de SQANTI3
out_dir=$3 # Directorio para los ficheros de salida

# Filtrado del classification
echo "Filtrado del classification:"
Rscript $utilities/filterClassification.R $sqanti_output_dir $sqanti_prefix $out_dir

# Filtrado del sam del mapeo de los tránscritos a partir del classification
echo "Filtrado y ordenado del sam:"
python $utilities/filter_sam.py ${out_dir}/filtered_${sqanti_prefix}_classification.txt \
    ${sqanti_output_dir}/${sqanti_prefix}_corrected.sam $out_dir

# Uso del sam filtrado para el colapso utilizando TAMA
cd $out_dir
# Ordenado
samtools sort -u -o sorted_${sqanti_prefix}.sam -O sam -@ 4 filtered_${sqanti_prefix}_corrected.sam

# TAMA collapse
conda activate tama
echo "Colapso a nivel del isoforma:"
python ${tama_dir}tama_collapse.py -s ${out_dir}/sorted_${sqanti_prefix}.sam -f $genoma\
    -p $out_dir/${sqanti_prefix} -x no_cap -m 100 -z 100

conda activate lrgasp2
#Convertir a GTF
python ${utilities}/bed2gtf.py ${sqanti_prefix}.bed

# Correr SQANTI3 en el gtf
mkdir ${out_dir}/SQANTI3
cd $SQ_folder
echo "SQANTI3 sobre las isoformas colapsadas:"
python sqanti3_lrgasp.challenge3.py ${out_dir}/${sqanti_prefix}.gtf $anotacion $genoma \
	--experiment_json ${SQ_utilities}experiment_dummy.json \
    --entry_json ${SQ_utilities}entry_dummy.json \
	-c $SR -d ${out_dir}/SQANTI3 \
	-o $sqanti_prefix -t 8 -g --skip_report

cd $out_dir

# Colapsar teniendo en cuenta el aliniamiento de proteínas para 
# una identidad del 80 % 
conda activate busco

echo "Collapso a nivel de proteína:"
cd-hit -o ${sqanti_prefix}.cdhit -c 0.8 -i SQANTI3/${sqanti_prefix}_corrected.faa -p 1 -d 0 -T 4 -M 48000

# Comprobar la redundancia depués de colapsar
echo "BUSCO anlysis post-colapso:"
busco -m protein -i ${sqanti_prefix}.cdhit -o busco_cdhit -l eutheria_odb10 \
    -c 4 --offline --download_path $BUSCO_dir

# Identificadores de los tránscritos que hay que mantener
echo "Filtrado final"
grep ">" ${sqanti_prefix}.cdhit | cut -f2 -d">" | cut -f1 > cdhit.lst 

# Filtrado del GTF con información de la CDS producido por SQANTI
python ${utilities}/filter_gtf.py ${out_dir}/cdhit.lst \
    ${out_dir}/SQANTI3/${sqanti_prefix}_corrected.gtf.cds.gff \
    ${out_dir}

mkdir AUGUSTUS
