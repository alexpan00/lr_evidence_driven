#!/bin/bash
# Wrapper del script gff2Augustus.sbatch para iniciar varios jobs con
# distintas longitudes de la región flanqueante

# Parámetros
gff=$1      # gff/gtf con los modelos de los genes de confianza
genoma=$2   # genoma de referencia
fr=$3       # longitud de la región flanqueantes a testear (ej: 1000,2000)
out_dir=$4  # Directorio de trabajo
out_name=$5 # Nombre para la especie y los fichero de salida
#subsets=$6 # Tamaño de los subsets de entrenamiento
seed=$6     # semilla para la generación de lso subsets

# PATHS
utilities="/home/apadepe/utilities/"

# Creación de un array a partir de los valores separados por comas
arrIN=(${fr//,/ })

# Creación de un directorio padre dentro del cual se crearan los directorios
# para los resultados de cada tamaño de la región flanqueante
mkdir $out_dir
# iterar por los distintos tamaños de la región flanqueante
for i in "${arrIN[@]}"
do
    echo "Flanking region $i"
    sbatch --output AUGUSTUS_fr$i.log --job-name=AUGUSTUS_fr$i \
    ${utilities}gff2Augustus.sbatch $gff $genoma \
    $i $out_dir/fr$i ${out_name}_fr$i
  
done