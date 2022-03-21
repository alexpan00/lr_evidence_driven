# Comprobar los argumentos que se le han pasado al script
if [ -z "$1" ] || [ $1 == '-h' ]
then
    echo "Argumentos esperados:"
    echo -e "\tgtf/gff"
    echo -e "\tUTR (TRUE/FALSE)"
    echo -e "\tSource (M,PB,...)"
    echo -e "\tchromosome"
    exit 0
fi

pwd;date
# module load conda
source activate busco

# PATH
utilities="/home/apadepe/utilities/"

# Parámetros
gff=$1      # gtf to be converted to hits
utr=$2      # include or exclude utr
src=$3      # Source of the information (M,PB)
wd=$4       # Working directory
name=$5     # Name for the output
chr=$6      # Do for only one chromosome

cd $wd
if [ -n "$chr" ]
then
    grep $chr $gff > tmp.gff
    gff="tmp.gff"
fi

if [ "$utr"  == "TRUE" ]
then
    grep -P "\t(CDS|exon)\t" $gff | gtf2gff.pl --printIntron --out=tmp.gff
    grep -P "\t(CDS|intron|exon)\t" tmp.gff > tmp2.gff
else
    grep -P "\t(CDS)\t" $gff | gtf2gff.pl --printIntron --out=tmp.gff
    grep -P "\t(CDS|intron)\t" tmp.gff > tmp2.gff
fi
rm tmp.gff
sed -i 's/gene_id \"/grp=/g' tmp2.gff
cut -f1 -d'"' tmp2.gff | sed 's/$/;pri=1;src=M/g' > $name.hits.gff
rm tmp2.gff


