#!/bin/bash
#SBATCH --job-name=fr_1000 # Job name
#SBATCH --partition=short # Partition (queue)
#SBATCH --ntasks=1 
#SBATCH --mail-type=ALL
#SBATCH --cpus-per-task=1 # Number of tasks = cpus
#SBATCH --mem-per-cpu=30gb # Job memory request
#SBATCH --time=0-24:00:00 # Time limit days-hrs:min:sec
#SBATCH --output=Augustus_subsets.log # Standard output and error log

# Script para ir desde un gff/gtf hasta correr Augustus para distintos tamaños
# de set de entreanmiento, longitudes de la FR y generar los plots

# Comprobar los argumentos que se le han pasado al script
if [ -z "$1" ] || [ $1 == '-h' ]
then
    echo "Argumentos esperados:"
    echo -e "\tgtf/gff"
    echo -e "\tgenoma"
    echo -e "\tlongitud de la región flanqeante"
    echo -e "\tdirectorio de salida (no debe existir)"
    echo -e "\tnombre de los ficheros de salida"
    # echo -e "\ttamño de los subsets de entranamiento (ej. 200,1000,1500)"
    echo -e "\tsemilla para genrar los sets (opcional, valor por defecto = 123)"
    exit 0
fi

pwd;date
# module load conda
source activate busco

# PATH
utilities="/home/apadepe/utilities/"
chr19="/home/apadepe/practicas/reference_human/chr19.fa"
ref="/home/apadepe/practicas/reference_human/chr19_CDS_LO.gtf"

# Parámetros
gff=$1      # gff/gtf con los modelos de los genes de confianza
genoma=$2   # genoma de referencia
fr=$3       # longitud de la región flanqueante para el formato GB
out_dir=$4  # Directorio de trabajo
out_name=$5 # Nombre para la especie y los fichero de salida
#subsets=$6 # Tamaño de los subsets de entrenamiento
seed=$6     # semilla para la generación de lso subsets


# Run info
echo "Genoma: $genoma"
echo "GTF/GFF: $gff"
echo "Longitud de la región flanqueante: $fr"
#echo "Tamaño de los conjuntos de entrenamiento: $subsets"
echo "Directorio de salida: $out_dir"
echo "Nombre del los fichero de salida: $out_name"
if [ -z "$6" ]
then
    echo "Semilla: 123"
else
    echo "Semilla: $seed"
fi

# Crear el directorio de salida
mkdir $out_dir

# Generación del archvio en formato gb
echo "Creación del archivo en formato GeneBank"
gff2gbSmallDNA.pl $gff $genoma $fr $out_dir/$out_name.gb

# Generación del set de entranemiento
# Esto podría cambiarse por un script que genere set random de verdad para 
# poder hacer bootstrap
cd $out_dir


# Generación de los subsets a partir del set de entrenamiento
echo "Generación se los subconjuntos de entrenameinto"

# Cálculo del tamaño de los subsets
subsets=$(python3 ${utilities}autosubsets.py `grep -c LOCUS ${out_name}.gb`)

mkdir results
echo "tamaño de los subsets: $subsets"
python3 ${utilities}generate_subsets.py ${out_name}.gb $out_name `pwd`/\
    -l $subsets --seed $seed
cd results

echo "Entrenamiento de los modelos"
# Script para la creación de una nueva especie en Augustus
for file in *.gb
do
    echo $file
    arrIN=(${file//./ })
    new_species.pl --species=${arrIN[0]}
    # Primera run the etraining, servirá para comprobar si los codones de stop
    # forman parte de las cds
    # Se corre el etraining
    etraining --species=${arrIN[0]} $file &> ${arrIN[0]}_etrain.out

    # Se checkea en el output cuantos genes no tienen StopCodon
    echo "NO stop codon:"
    grep -c "Variable stopCodonExcludedFromCDS set right" ${arrIN[0]}_etrain.out

    # Para ello creo una lista con los genes problemáticos bad.lst
    grep "in sequence" ${arrIN[0]}_etrain.out | cut -f7 -d" " | sed s/://g | sort -u > ${arrIN[0]}_bad.lst

    # Se usa la lista para filtrar los genes
    filterGenes.pl ${arrIN[0]}_bad.lst $file > ${arrIN[0]}.f.gb
done

# Una vez que se tiene los archivos con los genes filtrados se entrena los modelos
echo "Testeo de los modelos"
for file in subset*.f.gb
do
    echo $file
    date
    arrIN=(${file//./ })
    # Entrenamiento de los parámetros
    etraining --species=${arrIN[0]} $file &> ${arrIN[0]}_etrain.f.out
    # frecuencia de los codones de stop
    tail -6 ${arrIN[0]}_etrain.f.out | head -3 > ${arrIN[0]}_SC_freq.txt
    # Modificación de los parametros de la especie con la frecuencia adecuada
    python3 ${utilities}modify_SC_freq.py ${arrIN[0]}_SC_freq.txt ${arrIN[0]}
    # Correr Augustus con el set de prueba 
    augustus --species=${arrIN[0]} $chr19 --protein=off > ${arrIN[0]}.gtf
    date
done
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
echo "Generating summary:"
sbatch ${utilities}get_stats_WTC11.sbatch `pwd`
#Rscript ${utilities}plots.R `pwd` $out_name
