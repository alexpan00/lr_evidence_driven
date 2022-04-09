'''
Script that uses the output of cd-hit to filter a gtf file
'''

import os
import argparse

def main():
    parser = argparse.ArgumentParser(description="filter GTF file")
    parser.add_argument("lst",
                        help="File with the transcripts to be kept")
    parser.add_argument("gtf",
                        help="GTF that will be filtered")
    parser.add_argument("out_dir",
                        help="output path")
    args = parser.parse_args()
    l_genes = []
    gtf_basename = os.path.basename(args.gtf)

    # Save the transcripts in a list
    with open(args.lst, "r") as f_in:
        for linea in f_in:
            l_genes.append(linea.strip())
    
    f_out = open(args.out_dir + "/filtered_" + gtf_basename, "w")
    # Read the gtf file
    with open(args.gtf, "r") as f_in:
        for linea in f_in:
            # If the transcript id is in the list keep it
            transcript_id = linea.split('"')[3]
            if transcript_id in l_genes:
                f_out.write(linea)
    f_out.close()

if __name__=="__main__":
    main()
