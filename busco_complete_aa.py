'''
Script que permite obtener las secuencias fasta de todos los genes que se
encuentran en una sola copia en el genoma
'''
import os
from Bio import SeqIO
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("path")
    parser.add_argument("out_dir")
    args = parser.parse_args()
    path = args.path
    out_dir = args.out_dir
    archivos = os.listdir(path)
    l_records = []
    for archivo in archivos:
        if archivo.endswith("faa"):
            record = SeqIO.read(path + archivo, "fasta")
            record.id = archivo.split(".")[0]
            record.description = archivo.split(".")[0]
            l_records.append(record)
    SeqIO.write(l_records, out_dir + "/complete_buscos.faa", "fasta")

if __name__=="__main__":
    main()