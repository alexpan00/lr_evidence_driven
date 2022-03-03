'''
Script para leer el fichero de realción isoforma reads de FLAIR y generar
un archivo con conteos, renombrar las isoformas tanto en ese fichero como
en el fichero de isoformas en formato fasta
'''

import argparse


def count_rename(in_file, name, wd)-> dict:
    # Diccionario nombre viejo nombre nuevo
    d_names = dict()
    # fichero de salida
    out_file = wd + "/" + name + "_counts.csv"
    # Se escribe la cabecera
    f_out = (out_file, "w")
    f_out.write("id,sample1\n")
    # Recorrer el fichero de entrada
    with open(in_file, "r") as f_in:
        for i, linea in enumerate(f_in,1):
            # La linea contiene los trásncritos y las reads asociadas
            transcript, reads = linea.split()
            new_name = "ONT" + str(i)
            d_names[transcript] = new_name
            # Se cuenta el número de reads, los id están separados por comas
            n_reads = str(len(reads.split(","))) 
            # Se ecribe el conteo al fichero
            f_out.write(new_name + "," + n_reads + "\n")
    
    f_out.close()
    return d_names

def rename_fasta(d_names, prefix, wd):
    in_file = wd + "/" + prefix + ".isoforms.fa"
    out_file = wd + "/renamed_" + prefix + ".isoforms.fa"
    f_out = open(out_file, "w")
    with open(in_file, "r") as f_in:
        for linea in f_in:
            if linea.startswith(">"):
                transcript = linea.strip(">").rstrip()
                new_name = d_names[transcript]
                f_out.write(">" + new_name + "\n")
            else:
                f_out.write(linea)
    f_out.close()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("prefix") # Prefijo de los archvivos de FLAIR
    parser.add_argument("wd") # DIrectorio donde se encuentran los archivos
    args = parser.parse_args()
    in_file_counts = args.wd + "/" + args.prefix + ".isoform.read.map.txt"
    d_names = count_rename(in_file_counts, args.prefix, args.wd)
    rename_fasta(d_names, args.prefix, args.wd)

if __name__=="__main__":
    main()
     
