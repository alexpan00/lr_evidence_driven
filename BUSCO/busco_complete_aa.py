'''
Scripts to obtain the protein sequences in fasta foramt from all the BUSCO 
genes that where found in single copy in the genome
'''
import os
from Bio import SeqIO
import argparse

def main():
    parser = argparse.ArgumentParser(description="Get protein sequences of the found BUSCO genes")
    parser.add_argument("path",
                        help="path to the file containing the individual fasta")
    parser.add_argument("out_dir",
                        help="path to write the output")
    args = parser.parse_args()
    path = args.path
    out_dir = args.out_dir
    # The BUSCO output is a individual fasta for each gene that was found in the 
    # genome. All of this fasta are stored in the same path. 
    archivos = os.listdir(path)
    l_records = []
    for archivo in archivos:
        # Protein sequences fasta end with faa while nucleotide sequences 
        # end with fasta. In this case the protein sequences are obtained
        if archivo.endswith("faa"):
            # The header of the fasta file is not informative, while the name
            # of the file is, because it is the orthoDB id of the sequence.
            # The header of the fasta is replace by the orthoDB id
            record = SeqIO.read(path + "/" + archivo, "fasta")
            record.id = archivo.split(".")[0]
            record.description = archivo.split(".")[0]
            l_records.append(record)
    SeqIO.write(l_records, out_dir + "/complete_buscos.faa", "fasta")

if __name__=="__main__":
    main()