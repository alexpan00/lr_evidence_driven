'''
Este script utiliza un classification filtrado para mantener los tráncritos de
interés para filtrar un sam con los mapeos correspondiente a dichos
tránscritos.
'''

import argparse
from ast import arg
import os

def parse_classification(classification: str)-> list:
    '''
    Parsear el archivo clasification para quedarse solo con el nombre de
    los tránscritos en una lista
    ''' 
    l_transcripts = list()
    with open(classification, "r") as f_in:
        for i, linea in enumerate(f_in):
            # Se parsean todas las lineas menos el header
            if i != 0:
                
                ll = linea.split()

                l_transcripts.append(ll[0])
    return l_transcripts

def main():
    parser = argparse.ArgumentParser()
    # Classification file
    parser.add_argument("classification")
    # Fasta file
    parser.add_argument("sam")
    parser.add_argument("out_dir")
    args = parser.parse_args()
    # Leer tránscritos del clasification
    l_transcripts = parse_classification(args.classification)
    # Abrir el sam nuevo
    sam_basename = os.path.basename(args.sam)
    f_out = open(args.out_dir + "/" + "filtered_" + sam_basename, "w")
    # Abrir el sam a filtrar
    with open(args.sam, "r") as f_in:
        for linea in f_in:
            # Escribir la cabecera del sam
            if linea.startswith("@"):
                f_out.write(linea)
            # Escribir los tránscritos de interés
            else:
                ll = linea.split()
                if ll[0] in l_transcripts:
                    f_out.write(linea)
    f_out.close()
    
if __name__=="__main__":
    main()