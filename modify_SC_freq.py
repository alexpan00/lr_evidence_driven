'''
Script to modify th cfg file of a species to correct the frecuency of the stop
codons
'''
import argparse
import os

def main():
    AUGUSTUS_DIR = "/home/apadepe/.conda/envs/busco/config/species/"
    parser = argparse.ArgumentParser(description="Modify the Stop codon frequency")
    parser.add_argument("etrain", help="etrain output")
    parser.add_argument("species", help="Species to be modfied")
    args = parser.parse_args()
    d_freq = dict()
    # Get the frequency of the Stop codons from the etrain output
    with open(args.etrain, "r") as f_in:
        for linea in f_in:
            l_l = linea.split()
            codon = l_l[0].strip(":")
            freq = l_l[-1].strip("()")
            d_freq[codon] = freq
    
    # Path to the config file
    config_file = AUGUSTUS_DIR + \
                  args.species + \
                  "/" + args.species + \
                  "_parameters.cfg"
    config_file_modificado = config_file + ".tmp"
    f_out = open(config_file_modificado, "w")
    # Modify the config file
    with open(config_file, "r") as f_in:
        for linea in f_in:
            if linea.startswith("/Constant/amberprob"):
                linea = linea.replace("0.33", d_freq["tag"])
            elif linea.startswith("/Constant/ochreprob"):
                linea = linea.replace("0.33", d_freq["taa"])
            elif linea.startswith("/Constant/opalprob"):
                linea = linea.replace("0.34", d_freq["tga"])
            f_out.write(linea)
    f_out.close()
    # Replace the ild config file for the new one
    os.rename(config_file_modificado, config_file)

if __name__=="__main__":
    main()