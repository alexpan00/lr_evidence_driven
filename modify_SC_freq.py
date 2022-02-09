'''
Script para modificar el archivo .cfg de la especie correspondiente para poner
los valores de frecuencia de los condones de stop adecuados.
'''
import argparse
import os

def main():
    AUGUSTUS_DIR = "/home/apadepe/.conda/envs/busco/config/species/"
    parser = argparse.ArgumentParser()
    parser.add_argument("etrain")
    parser.add_argument("species")
    args = parser.parse_args()
    d_freq = dict()
    # Leer las frecuencias de los codones de stop 
    with open(args.etrain, "r") as f_in:
        for linea in f_in:
            l_l = linea.split()
            codon = l_l[0].strip(":")
            freq = l_l[-1].strip("()")
            d_freq[codon] = freq
    config_file = AUGUSTUS_DIR + args.species + "/" + args.species + "_parameters.cfg"
    config_file_modificado = config_file + ".tmp"
    f_out = open(config_file_modificado, "w")
    # Escribir las frecuencias de los codones de stop en el archivo config temporal
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
    # Remplazar el config por el config temporal
    os.rename(config_file_modificado, config_file)

if __name__=="__main__":
    main()