'''
Script para filtrar un gtf utilizando el nombre los tráncritos
'''

import os
import argparse

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("lst")
    parser.add_argument("gtf")
    parser.add_argument("out_dir")
    args = parser.parse_args()
    l_genes = []
    gtf_basename = os.path.basename(args.gtf)
    with open(args.lst, "r") as f_in:
        for linea in f_in:
            l_genes.append(linea.strip())
    
    f_out = open(args.out_dir + "filtered_" + gtf_basename, "w")
    with open(args.gtf, "r") as f_in:
        for linea in f_in:
            transcript_id = linea.split('"')[3]
            if transcript_id in l_genes:
                f_out.write(linea)
    f_out.close()

if __name__=="__main__":
    main()